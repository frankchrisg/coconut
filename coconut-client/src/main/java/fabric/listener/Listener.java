package fabric.listener;

import client.client.ClientObject;
import client.commoninterfaces.IListenerDisconnectionLogic;
import client.commoninterfaces.IListenerLogic;
import client.configuration.GeneralConfiguration;
import client.statistics.IStatistics;
import client.statistics.ListenerReferenceValues;
import client.supplements.ExceptionHandler;
import co.paralleluniverse.fibers.Suspendable;
import cy.agorise.graphenej.Util;
import fabric.configuration.Configuration;
import fabric.connection.FabricClient;
import fabric.helper.Utils;
import fabric.statistics.BlockStatisticObject;
import fabric.statistics.ListenerStatisticObject;
import org.apache.commons.lang3.tuple.MutablePair;
import org.apache.log4j.Logger;
import org.hyperledger.fabric.sdk.BlockEvent;
import org.hyperledger.fabric.sdk.ChaincodeEvent;
import org.hyperledger.fabric.sdk.ChaincodeEventListener;
import org.hyperledger.fabric.sdk.Channel;
import org.hyperledger.fabric.sdk.exception.InvalidArgumentException;

import java.util.List;
import java.util.Map;
import java.util.Queue;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

public class Listener implements IListenerDisconnectionLogic, IListenerLogic {

    private static final Logger LOG = Logger.getLogger(Listener.class);

    private static final Map<String, Map<String, MutablePair<Long, Long>>> OBTAINED_EVENTS_MAP =
            new ConcurrentHashMap<>();
    private static final AtomicBoolean STATS_RETRIEVED = new AtomicBoolean(false);
    private static final AtomicInteger RECEIVED_COUNTER = new AtomicInteger(0);
    private static final int DEFAULT_INVALID_VALUE = -1;
    private static final long DEFAULT_EXISTING_VALUE = -3;
    private int numberOfExpectedEvents;
    private final CompletableFuture<Boolean> done = new CompletableFuture<>();
    private double threshold;
    private final Queue<IStatistics> iStatistics;

    public int getNumberOfExpectedEvents() {
        return numberOfExpectedEvents;
    }

    public void setNumberOfExpectedEvents(final int numberOfExpectedEvents) {
        this.numberOfExpectedEvents = numberOfExpectedEvents;
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

    public double getTotalThreshold() {
        return totalThreshold;
    }

    public void setTotalThreshold(final double totalThreshold) {
        this.totalThreshold = totalThreshold;
    }

    private int totalNumberOfExpectedEventsPerClient;
    private double totalThreshold;
    private final CompletableFuture<Boolean> isSubscribed = new CompletableFuture<>();
    private final AtomicBoolean statsSet = new AtomicBoolean(false);

    public AtomicInteger getCurrentNumberOfEventsPerClient() {
        return currentNumberOfEventsPerClient;
    }

    public void setCurrentNumberOfEventsPerClient(final AtomicInteger currentNumberOfEventsPerClient) {
        this.currentNumberOfEventsPerClient = currentNumberOfEventsPerClient;
    }

    private AtomicInteger currentNumberOfEventsPerClient = new AtomicInteger(0);

    public Listener(final int numberOfExpectedEventsConstructor,
                    final int totalNumberOfExpectedEventsPerClientConstructor,
                    final double thresholdConstructor,
                    final double totalThresholdConstructor,
                    final Queue<IStatistics> iStatisticsConstructor) {
        this.numberOfExpectedEvents = numberOfExpectedEventsConstructor;
        this.threshold = thresholdConstructor;
        this.totalNumberOfExpectedEventsPerClient = totalNumberOfExpectedEventsPerClientConstructor;
        this.iStatistics = iStatisticsConstructor;
        this.totalThreshold = totalThresholdConstructor;
    }

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
    public static synchronized void unregisterAndUnsetAll(final String handle, final boolean
            chainCodeEventListener, final Channel channel) {
        LOG.info(handle + " unregistered as" + (chainCodeEventListener ? " chaincode" : " block") +
                "Listener");
        try {
            if (chainCodeEventListener) {
                channel.unregisterChaincodeEventListener(handle);
            } else {
                channel.unregisterBlockListener(handle);
            }
        } catch (InvalidArgumentException ex) {
            ExceptionHandler.logException(ex);
        }
    }

    @Suspendable
    @Override
    public CompletableFuture<Boolean> isDone() {
        return done;
    }

    @SafeVarargs
    @Override
    @Suspendable
    public synchronized final <E> Queue<IStatistics> getStatistics(final E... params) {
        if (statsSet.get() && !STATS_RETRIEVED.get()) {
            STATS_RETRIEVED.set(true);
            return iStatistics;
        } else {
            return new ConcurrentLinkedQueue<>();
        }
    }

    @Override
    @Suspendable
    public synchronized void setStatisticsAfterTimeout() {
        if (!statsSet.get()) {
            ListenerStatisticObject listenerStatisticObject = new ListenerStatisticObject();
            listenerStatisticObject.setObtainedEventsMap(OBTAINED_EVENTS_MAP);
            listenerStatisticObject.setSetThreshold(-1);
            listenerStatisticObject.setExpectedThreshold(threshold);
            listenerStatisticObject.setSetTotalThreshold(totalThreshold);
            iStatistics.add(listenerStatisticObject);
            statsSet.set(true);
        }
    }

    @Suspendable
    public String registerChaincodeListener(final FabricClient fabricClientConstructor, final Pattern chainCodeId,
                                            final Pattern eventName, final String channel,
                                            final Queue<ClientObject> clientObclientObjectQueue) {

        String handle = "";
        try {
            handle =
                    fabricClientConstructor.getInstance().getChannel(channel).registerChaincodeEventListener(chainCodeId,
                            eventName,
                            new ChaincodeEventListener() {
                                @Override
                                //@Suspendable
                                public void received(String handle, BlockEvent blockEvent,
                                                     ChaincodeEvent chaincodeEvent) {
                                    LOG.debug("Event name: " + chaincodeEvent.getEventName() + " | " + "Payload: " + new String(chaincodeEvent.getPayload()) + " | " + "Handle: " + handle
                                            + " | " + "ChaincodeId: " + chaincodeEvent.getChaincodeId() + " Peer: " + blockEvent.getPeer().getName());
                                    LOG.info("Received transaction from listener: " + chaincodeEvent.getTxId());

                                    if (Configuration.PEERS_TO_EXPECT_EVENTS_FROM.size() == 0 || Configuration.PEERS_TO_EXPECT_EVENTS_FROM.contains(blockEvent.getPeer().getName())) {
                                        handleEvent(chaincodeEvent, clientObclientObjectQueue);
                                    } else {
                                        LOG.debug("Peer not in list for receiving events: " + blockEvent.getPeer().getName());
                                    }

                                }
                            }
                    );
            isSubscribed.complete(true);
        } catch (InvalidArgumentException ex) {
            ExceptionHandler.logException(ex);
        }
        return handle;
    }

    @Suspendable
    private void handleEvent(final ChaincodeEvent chaincodeEvent, final Queue<ClientObject> clientObjectQueue) {

        String expectedValue = chaincodeEvent.getEventName() + " " + new String(chaincodeEvent.getPayload());

        if (Configuration.HANDLE_EVENT_SYNCHRONIZED) {
            synchronized (OBTAINED_EVENTS_MAP) {
                handleEventLogic(clientObjectQueue, expectedValue);
            }
        } else {
            handleEventLogic(clientObjectQueue, expectedValue);
        }
    }

    @Suspendable
    private void handleEventLogic(final Queue<ClientObject> clientObjectQueue, final String expectedValueParam) {
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
                            if (!statsSet.get() && (checkThreshold(totalThreshold, receivedCounter,
                                    totalNumberOfExpectedEventsPerClient
                                    , true) || (getExternalTotalCounter().get() == receivedCounter && externalFinished.get()))) {
                                synchronized (this) {
                                    if (!statsSet.get()) {
                                        ListenerStatisticObject listenerStatisticObject = new ListenerStatisticObject();
                                        listenerStatisticObject.setObtainedEventsMap(OBTAINED_EVENTS_MAP);
                                        listenerStatisticObject.setSetThreshold(((double) receivedCounter / numberOfExpectedEvents));
                                        listenerStatisticObject.setExpectedThreshold(threshold);
                                        listenerStatisticObject.setSetTotalThreshold(totalThreshold);
                                        iStatistics.add(listenerStatisticObject);
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

                    //for (final String event : Configuration.EVENT_EXISTS_SUFFIX_LIST) {
                    String finalExpectedValue = expectedValue;
                    Configuration.EVENT_EXISTS_SUFFIX_LIST.parallelStream().forEach(event -> {
                        if (!finalExpectedValue.endsWith(event)) {
                            LOG.debug("Not checking for existing event");
                        } else {
                            if (OBTAINED_EVENTS_MAP.get(id).get(finalExpectedValue.replace(event, "")) != null) {
                                MutablePair<Long, Long> longLongMutablePair =
                                        OBTAINED_EVENTS_MAP.get(id).get(finalExpectedValue.replace(event, ""));
                                if (longLongMutablePair.getRight() != DEFAULT_INVALID_VALUE) {
                                    LOG.error("Updating already existing value " + finalExpectedValue.replace(event, "") + " - possible duplicate" +
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
                                                finalExpectedValue.replace(event, ""),
                                                longLongMutablePair);

                                LOG.debug(id + " received expected value (existing): " + finalExpectedValue.replace(event,
                                        ""));
                                int i = currentNumberOfEventsPerClient.incrementAndGet();
                                int receivedCounter = RECEIVED_COUNTER.incrementAndGet();
                                if (checkThreshold(threshold, i, numberOfExpectedEvents,
                                        false) || (getExternalTotalCounter().get() == receivedCounter && externalFinished.get())) {
                                    if (!statsSet.get() && (checkThreshold(totalThreshold, receivedCounter,
                                            totalNumberOfExpectedEventsPerClient
                                            , true) || (getExternalTotalCounter().get() == receivedCounter && externalFinished.get()))) {
                                        synchronized (this) {
                                            if (!statsSet.get()) {
                                                ListenerStatisticObject listenerStatisticObject =
                                                        new ListenerStatisticObject();
                                                listenerStatisticObject.setObtainedEventsMap(OBTAINED_EVENTS_MAP);
                                                listenerStatisticObject.setSetThreshold(((double) receivedCounter / numberOfExpectedEvents));
                                                listenerStatisticObject.setExpectedThreshold(threshold);
                                                listenerStatisticObject.setSetTotalThreshold(totalThreshold);
                                                iStatistics.add(listenerStatisticObject);
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

            MutablePair<Long, Long> removeObtainedEvents = OBTAINED_EVENTS_MAP.get(id).remove(splitEvent[0].trim());
            MutablePair<Long, Long> removeListenerReferenceValues = ListenerReferenceValues.getTimeMap().get(id).remove(splitEvent[0].trim());
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

    @Suspendable
    public CompletableFuture<Boolean> getIsSubscribed() {
        return isSubscribed;
    }

    @Suspendable
    public String registerBlockListener(final FabricClient fabricClientConstructor, final String channel,
                                        final List<ClientObject> clientObjectList) {

        String handle = "";

        LOG.debug("Channel to register listener for: " + channel);
        Channel channelToRegisterListenerFor = fabricClientConstructor.getInstance().getChannel(channel);

        try {
            handle = channelToRegisterListenerFor.registerBlockListener(blockEvent -> {

                LOG.info("Received block from listener: " + Util.bytesToHex(blockEvent.getDataHash()) + " from peer: "
                        + blockEvent.getPeer().getName());

                BlockStatisticObject blockStatisticObject = new BlockStatisticObject();
                blockStatisticObject.setBlockId(Util.bytesToHex(blockEvent.getDataHash()));
                blockStatisticObject.setReceivedTime(System.currentTimeMillis());
                blockStatisticObject.setClientId(clientObjectList.stream().map(ClientObject::getClientId).collect(Collectors.toList()).toString());
                blockStatisticObject.setNumberOfTransactions(blockEvent.getTransactionCount());
                blockStatisticObject.setNumberOfActions(blockEvent.getTransactionCount());
                blockStatisticObject.setBlockNum(blockEvent.getBlockNumber());
                blockEvent.getTransactionEvents().forEach(transactionEvent -> blockStatisticObject.getTxIdList().add(transactionEvent.getTransactionID()));
                iStatistics.add(blockStatisticObject);

                if (Configuration.PRINT_BLOCK) {
                    Utils.printBlock(blockEvent, fabricClientConstructor);
                }
                if (Configuration.PARSE_BLOCK) {
                    Utils.parseBlockByRegex(blockEvent);
                }
            });
        } catch (InvalidArgumentException ex) {
            ExceptionHandler.logException(ex);
        }

        /*ArrayBlockingQueue<QueuedBlockEvent> queuedBlockEvents = new ArrayBlockingQueue<>(10);
          String handle = channelToRegisterListenerFor.registerBlockListener(queuedBlockEvents);
          QueuedBlockEvent poll = queuedBlockEvents.poll();
          if (poll != null)*/

        LOG.info("Handle, block listener: " + handle);
        return handle;

    }

    @SafeVarargs
    @Override
    @Suspendable
    public final <E> void handleEvent(final E... params) {
        ChaincodeEvent chaincodeEvent = (ChaincodeEvent) params[0];
        List<ClientObject> clientObjectList = (List<ClientObject>) params[1];
        handleEvent(chaincodeEvent, clientObjectList);
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
