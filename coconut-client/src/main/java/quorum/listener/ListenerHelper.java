package quorum.listener;

import client.client.ClientObject;
import client.commoninterfaces.IListenerLogic;
import client.configuration.GeneralConfiguration;
import client.statistics.IStatistics;
import client.statistics.ListenerReferenceValues;
import co.paralleluniverse.fibers.Suspendable;
import org.apache.commons.lang3.tuple.MutablePair;
import org.apache.log4j.Logger;
import org.web3j.abi.FunctionReturnDecoder;
import org.web3j.abi.TypeReference;
import org.web3j.abi.Utils;
import org.web3j.abi.datatypes.Address;
import org.web3j.abi.datatypes.Type;
import org.web3j.protocol.core.methods.response.Log;
import quorum.configuration.Configuration;
import quorum.statistics.ListenerStatisticObject;

import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;

public class ListenerHelper implements IListenerLogic {

    private static final Logger LOG = Logger.getLogger(ListenerHelper.class);

    private static final Map<String, Map<String, MutablePair<Long, Long>>> OBTAINED_EVENTS_MAP =
            new ConcurrentHashMap<>();
    private static final AtomicBoolean STATS_RETRIEVED = new AtomicBoolean(false);
    private static final AtomicInteger RECEIVED_COUNTER = new AtomicInteger(0);
    private static final int DEFAULT_INVALID_VALUE = -1;
    private static final long DEFAULT_EXISTING_VALUE = -3;
    private final AtomicBoolean statsSet = new AtomicBoolean(false);
    private final Queue<IStatistics> iStatistics = new ConcurrentLinkedQueue<>();
    private AtomicInteger currentNumberOfEventsPerClient = new AtomicInteger(0);

    public ListenerHelper(final int numberOfExpectedEventsConstructor, final int totalNumberOfExpectedEventsPerClientConstructor, final double thresholdConstructor, final double totalThresholdConstructor) {
        this.numberOfExpectedEvents = numberOfExpectedEventsConstructor;
        this.threshold = thresholdConstructor;
        this.totalNumberOfExpectedEventsPerClient = totalNumberOfExpectedEventsPerClientConstructor;
        this.totalThreshold = totalThresholdConstructor;
    }

    public ListenerHelper() {
    }

    public AtomicInteger getCurrentNumberOfEventsPerClient() {
        return currentNumberOfEventsPerClient;
    }

    public void setCurrentNumberOfEventsPerClient(final AtomicInteger currentNumberOfEventsPerClient) {
        this.currentNumberOfEventsPerClient = currentNumberOfEventsPerClient;
    }

    public int getNumberOfExpectedEvents() {
        return numberOfExpectedEvents;
    }

    public void setNumberOfExpectedEvents(final int numberOfExpectedEvents) {
        this.numberOfExpectedEvents = numberOfExpectedEvents;
    }

    public double getTotalThreshold() {
        return totalThreshold;
    }

    public void setTotalThreshold(final double totalThreshold) {
        this.totalThreshold = totalThreshold;
    }

    public double getThreshold() {
        return threshold;
    }

    public void setThreshold(final double threshold) {
        this.threshold = threshold;
    }

    public int getTotalNumberOfExpectedEventsPerClient() {
        return totalNumberOfExpectedEventsPerClient;
    }

    public void setTotalNumberOfExpectedEventsPerClient(final int totalNumberOfExpectedEventsPerClient) {
        this.totalNumberOfExpectedEventsPerClient = totalNumberOfExpectedEventsPerClient;
    }

    private int numberOfExpectedEvents;
    private double totalThreshold;
    private double threshold;
    private int totalNumberOfExpectedEventsPerClient;

    private static final AtomicInteger externalTotalCounter = new AtomicInteger(0);

    public static AtomicInteger getExternalTotalCounter() {
        return externalTotalCounter;
    }

    private static final AtomicBoolean externalFinished = new AtomicBoolean(false);

    public static AtomicBoolean getExternalFinished() {
        return externalFinished;
    }

    @Suspendable
    public static Map<String, Map<String, MutablePair<Long, Long>>> getObtainedEventsMap() {
        return OBTAINED_EVENTS_MAP;
    }

    @Suspendable
    public synchronized void setStatisticsAfterTimeout(final double threshold, final double totalThreshold) {
        if(!statsSet.get()) {
            ListenerStatisticObject listenerStatisticObject = new ListenerStatisticObject();
            listenerStatisticObject.setObtainedEventsMap(OBTAINED_EVENTS_MAP);
            listenerStatisticObject.setSetThreshold(-1);
            listenerStatisticObject.setExpectedThreshold(threshold);
            listenerStatisticObject.setSetTotalThreshold(totalThreshold);
            this.iStatistics.add(listenerStatisticObject);
            statsSet.set(true);
        }
    }

    @Suspendable
    public AtomicBoolean getStatsSet() {
        return statsSet;
    }

    @Suspendable
    public synchronized Queue<IStatistics> getStatistics() {
        if (statsSet.get() && !STATS_RETRIEVED.get()) {
            STATS_RETRIEVED.set(true);
            return iStatistics;
        } else {
            return new ConcurrentLinkedQueue<>();
        }
    }

    @Suspendable
    public void decodeListenerEvent(final Log event, final List<TypeReference<?>> typeReferenceList,
                                    final Queue<ClientObject> clientObjectQueue,
                                    final CompletableFuture<Boolean> done,
                                    final Queue<IStatistics> iStatistics) {

        LOG.debug("Event type: " + event.getType() + " List topics size: " + event.getTopics().size());

        for (final String topic : event.getTopics()) {
            LOG.debug("Topic: " + topic);
        }

        LOG.debug("Decoded index value: " + FunctionReturnDecoder.decodeIndexedValue(event.getData(),
                TypeReference.create(Address.class)));

        List<TypeReference<Type>> convertedTypeReferenceList = Utils.convert(typeReferenceList);
        LOG.debug("Decoded data: " + FunctionReturnDecoder.decode(event.getData(), convertedTypeReferenceList));

        for (final Type<?> type : FunctionReturnDecoder.decode(event.getData(), convertedTypeReferenceList)) {
            LOG.debug("Type value: " + type.getValue() + " Type as string " + type.getTypeAsString());
        }

        handleEvent(event, clientObjectQueue, convertedTypeReferenceList, numberOfExpectedEvents,
                totalNumberOfExpectedEventsPerClient, done, threshold, totalThreshold,
                iStatistics);
    }

    @Suspendable
    private void handleEvent(final Log event, final Queue<ClientObject> clientObjectQueue,
                             final List<TypeReference<Type>> convertedTypeReferenceList,
                             final int numberOfExpectedEvents,
                             final int totalNumberOfExpectedEventsPerClient,
                             final CompletableFuture<Boolean> done, final double threshold, final double totalThreshold,
                             Queue<IStatistics> iStatistics) {

        String expectedValue = String.valueOf(FunctionReturnDecoder.decode(event.getData(),
                convertedTypeReferenceList));

        if (Configuration.HANDLE_EVENT_SYNCHRONIZED) {
            synchronized (OBTAINED_EVENTS_MAP) {
                handleEventLogic(clientObjectQueue, numberOfExpectedEvents, totalNumberOfExpectedEventsPerClient, done
                        , threshold
                        , totalThreshold, iStatistics, expectedValue);
            }
        } else {
            handleEventLogic(clientObjectQueue, numberOfExpectedEvents, totalNumberOfExpectedEventsPerClient, done,
                    threshold
                    , totalThreshold, iStatistics, expectedValue);
        }

    }

    @Suspendable
    private void handleEventLogic(final Queue<ClientObject> clientObjectQueue, final int numberOfExpectedEvents,
                                  final int totalNumberOfExpectedEventsPerClient, final CompletableFuture<Boolean> done,
                                  final double threshold, final double totalThreshold,
                                  final Queue<IStatistics> iStatistics,
                                  final String expectedValueParam) {
        if (!statsSet.get()) {

            if (done.isDone()) {
                return;
            }

            clientObjectQueue.parallelStream().forEach(clientObject -> {
                //for (final ClientObject clientObject : clientObjectQueue) {
                String id = clientObject.getClientId();
                if (OBTAINED_EVENTS_MAP.get(id) == null) {
                    LOG.debug("Unknown map entry: " + id);
                } else {
                    String expectedValue = expectedValueParam;

                    if(GeneralConfiguration.HANDLE_RETURN_EVENT) {
                        expectedValue = handleReturnEventLogic(expectedValue, id);
                    }

                    if (OBTAINED_EVENTS_MAP.get(id).get(expectedValue) != null) {
                        MutablePair<Long, Long> longLongMutablePair =
                                OBTAINED_EVENTS_MAP.get(id).get(expectedValue);
                        if (longLongMutablePair.getRight() != DEFAULT_INVALID_VALUE) {
                            LOG.error("Updating already existing value " + expectedValue + " - possible duplicate" +
                                    " event received");
                            if (Configuration.RETURN_ON_EVENT_DUPLICATE) {
                                LOG.error("Returned due to duplicated");
                                return;
                                //continue;
                            }
                        }
                        longLongMutablePair.setRight(System.nanoTime());
                        ListenerReferenceValues.getTimeMap().get(id).get(expectedValue).setRight(System.currentTimeMillis());

                        OBTAINED_EVENTS_MAP.get(id)
                                .replace(
                                        expectedValue,
                                        longLongMutablePair);

                        LOG.debug(id + " received expected value: " + expectedValue);
                        int i = currentNumberOfEventsPerClient.incrementAndGet();
                        int receivedCounter = RECEIVED_COUNTER.incrementAndGet();
                        if (checkThreshold(threshold, i, numberOfExpectedEvents,
                                false) || (getExternalTotalCounter().get() == receivedCounter && externalFinished.get())) {
                            if (!statsSet.get() && (checkThreshold(totalThreshold, receivedCounter, totalNumberOfExpectedEventsPerClient
                                    , true) || (getExternalTotalCounter().get() == receivedCounter && externalFinished.get()))) {
                                synchronized (this) {
                                    if(!statsSet.get()) {
                                        ListenerStatisticObject listenerStatisticObject = new ListenerStatisticObject();
                                        listenerStatisticObject.setObtainedEventsMap(OBTAINED_EVENTS_MAP);
                                        listenerStatisticObject.setSetThreshold(((double) receivedCounter / numberOfExpectedEvents));
                                        listenerStatisticObject.setExpectedThreshold(threshold);
                                        listenerStatisticObject.setSetTotalThreshold(totalThreshold);
                                        //iStatistics.add(listenerStatisticObject);
                                        //this.iStatistics.addAll(iStatistics);
                                        this.iStatistics.add(listenerStatisticObject);
                                        statsSet.set(true);
                                    }
                                }
                            }
                            done.complete(true);
                            return;
                        }

                    } else {
                        LOG.debug("Received event value: " + expectedValue + " not contained for key: " + id);
                    }

                    //for (final String existingEvent : Configuration.EVENT_EXISTS_SUFFIX_LIST) {
                    String finalExpectedValue = expectedValue;
                    Configuration.EVENT_EXISTS_SUFFIX_LIST.parallelStream().forEach(existingEvent -> {
                        if (!finalExpectedValue.endsWith(existingEvent)) {
                            LOG.debug("Not checking for existing event");
                        } else {
                            if (OBTAINED_EVENTS_MAP.get(id).get(finalExpectedValue.replace(existingEvent, "")) != null) {
                                MutablePair<Long, Long> longLongMutablePair =
                                        OBTAINED_EVENTS_MAP.get(id).get(finalExpectedValue.replace(existingEvent, ""));
                                if (longLongMutablePair.getRight() != DEFAULT_INVALID_VALUE) {
                                    LOG.error("Updating already existing value " + finalExpectedValue.replace(existingEvent, "") + " - possible duplicate" +
                                            " event received (existing)");
                                    if (Configuration.RETURN_ON_EVENT_DUPLICATE) {
                                        LOG.error("Returned due to duplicated (existing)");
                                        return;
                                        //continue;
                                    }
                                }
                                longLongMutablePair.setRight(DEFAULT_EXISTING_VALUE);
                                OBTAINED_EVENTS_MAP.get(id)
                                        .replace(
                                                finalExpectedValue.replace(existingEvent, ""),
                                                longLongMutablePair);

                                LOG.debug(id + " received expected value (existing): " + finalExpectedValue.replace(existingEvent, ""));
                                int i = currentNumberOfEventsPerClient.incrementAndGet();
                                int receivedCounter = RECEIVED_COUNTER.incrementAndGet();
                                if (checkThreshold(threshold, i,
                                        numberOfExpectedEvents,
                                        false) || (getExternalTotalCounter().get() == receivedCounter && externalFinished.get())) {
                                    if (!statsSet.get() && (checkThreshold(totalThreshold, receivedCounter,
                                            totalNumberOfExpectedEventsPerClient
                                            , true) || (getExternalTotalCounter().get() == receivedCounter && externalFinished.get()))) {
                                        synchronized (this) {
                                            if(!statsSet.get()) {
                                                ListenerStatisticObject listenerStatisticObject = new ListenerStatisticObject();
                                                listenerStatisticObject.setObtainedEventsMap(OBTAINED_EVENTS_MAP);
                                                listenerStatisticObject.setSetThreshold(((double) receivedCounter / numberOfExpectedEvents));
                                                listenerStatisticObject.setExpectedThreshold(threshold);
                                                listenerStatisticObject.setSetTotalThreshold(totalThreshold);
                                                //iStatistics.add(listenerStatisticObject);
                                                //this.iStatistics.addAll(iStatistics);
                                                this.iStatistics.add(listenerStatisticObject);
                                                statsSet.set(true);
                                            }
                                        }
                                    }
                                    done.complete(true);
                                    return;
                                }
                            }

                        }
                    });
                }
            });
        }
    }

    @SafeVarargs
    @Override
    public final <E> String handleReturnEventLogic(final E... params) {
        String event = String.valueOf(params[0]);
        String id = String.valueOf(params[1]);
        return handleReturnEventLogicIn(event, id);
    }

    @Suspendable
    private String handleReturnEventLogicIn(final String event,
                                            final String id) {

        String balanceEvent = "__balance_event:";

        if(event.contains(balanceEvent)) {
            String[] splitEvent = event.split(balanceEvent);

            MutablePair<Long, Long> removeObtainedEvents = OBTAINED_EVENTS_MAP.get(id).remove(splitEvent[0].trim() + "]");
            MutablePair<Long, Long> removeListenerReferenceValues = ListenerReferenceValues.getTimeMap().get(id).remove(splitEvent[0].trim() + "]");
            if(removeObtainedEvents != null) {
                OBTAINED_EVENTS_MAP.get(id).put(splitEvent[0].trim() + splitEvent[1].trim(), removeObtainedEvents);
            }
            if(removeListenerReferenceValues != null) {
                ListenerReferenceValues.getTimeMap().get(id).put(splitEvent[0].trim() + splitEvent[1].trim(), removeListenerReferenceValues);
            }
            return splitEvent[0].trim() + splitEvent[1].trim();
        }
        return event;
    }

    private static final double DONT_CHECK_THRESHOLD = -1.0;

    @Suspendable
    private boolean checkThreshold(final double threshold, final int currentNumberOfEvents,
                                   final int numberOfExpectedEvents, final boolean isTotal) {
        if (threshold == DONT_CHECK_THRESHOLD) {
            return false;
        }
        if (threshold <= ((double) currentNumberOfEvents / numberOfExpectedEvents)) {
            LOG.info("Reached threshold of " + threshold + " aborting with value: " + ((double) currentNumberOfEvents / numberOfExpectedEvents) + " current number of events: " + (double) currentNumberOfEvents + " number of expected events " + numberOfExpectedEvents
                    + " is total: " + isTotal);
            return true;
        }
        return false;
    }

    @SafeVarargs
    @Override
    @Suspendable
    public final <E> void handleEvent(final E... params) {
        Log event = (Log) params[0];
        Queue<ClientObject> clientObjectQueue = (Queue<ClientObject>) params[1];
        List<TypeReference<Type>> convertedTypeReferenceList = (List<TypeReference<Type>>) params[2];
        int numberOfExpectedEvents = (Integer) params[3];
        int totalNumberOfExpectedEventsPerClient = (Integer) params[4];
        CompletableFuture<Boolean> done = (CompletableFuture<Boolean>) params[5];
        final double threshold = (Double) params[6];
        final double totalThreshold = (Double) params[7];
        Queue<IStatistics> iStatistics = (Queue<IStatistics>) params[8];
        handleEvent(event, clientObjectQueue, convertedTypeReferenceList, numberOfExpectedEvents,
                totalNumberOfExpectedEventsPerClient,
                done, threshold, totalThreshold, iStatistics);
    }

    @SafeVarargs
    @Override
    @Suspendable
    public final <E> boolean checkThreshold(final E... params) {
        double threshold = (Double) params[0];
        int currentNumberOfEvents = (Integer) params[1];
        int numberOfExpectedEvents = (Integer) params[2];
        boolean isTotal = (Boolean) params[3];
        return checkThreshold(threshold, currentNumberOfEvents, numberOfExpectedEvents, isTotal);
    }
}
