package fabric.workloads;

import client.client.ClientObject;
import client.commoninterfaces.IExecuteWorkload;
import client.commoninterfaces.IListenerDisconnectionLogic;
import client.commoninterfaces.IRequestDistribution;
import client.configuration.GeneralConfiguration;
import client.statistics.IStatistics;
import client.statistics.ListenerReferenceValues;
import client.supplements.ExceptionHandler;
import client.utils.GenericSelectionStrategy;
import client.utils.NumberGenerator;
import co.paralleluniverse.fibers.SuspendExecution;
import co.paralleluniverse.fibers.Suspendable;
import co.paralleluniverse.strands.Strand;
import com.google.common.util.concurrent.RateLimiter;
import fabric.configuration.Configuration;
import fabric.listener.Listener;
import fabric.payload_patterns.IFabricPayloads;
import fabric.payloads.IFabricWritePayload;
import fabric.statistics.CustomStatisticObject;
import fabric.statistics.WriteStatisticObject;
import fabric.write.Write;
import org.apache.commons.lang3.tuple.ImmutablePair;
import org.apache.commons.lang3.tuple.MutablePair;
import org.apache.log4j.Logger;
import org.hyperledger.fabric.sdk.TransactionProposalRequest;

import java.lang.reflect.InvocationTargetException;
import java.time.Instant;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeoutException;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;

public class ExecuteFabricWorkloadTimeFrame implements IExecuteWorkload, IRequestDistribution {

    private static final Logger LOG = Logger.getLogger(ExecuteFabricWorkloadTimeFrame.class);
    private static final String WRITE_SUFFIX = "-write";
    private final Queue<IStatistics> iStatistics = new ConcurrentLinkedQueue<>();
    private int writeRequests;
    private static final AtomicBoolean IS_STOPPED = new AtomicBoolean(false);

    private static final AtomicInteger finishedCounter = new AtomicInteger(0);

    @SafeVarargs
    @Override
    @Suspendable
    public final <E> E executeWorkload(final E... params) {

        ClientObject clientObject = (ClientObject) params[1];
        int workloadId = Integer.parseInt(String.valueOf(params[2])) + 1;

        List<PrepareFabricWorkloadObject> listOfWorkloadObjects =
                GenericSelectionStrategy.selectFixed(((ArrayList<PrepareFabricWorkloadObject>) params[0]),
                        Collections.singletonList(0), false);
        PrepareFabricWorkloadObject prepareWorkloadObject = listOfWorkloadObjects.get(0);

        if (Configuration.SEND_WRITE_REQUESTS) {

            long startTime = System.currentTimeMillis();
            long maxDurationInMilliseconds = Configuration.RUNTIME;
            long runtime = startTime + maxDurationInMilliseconds;
            LOG.info("Client: " + clientObject.getClientId() + " workload: " + workloadId + " start time: " + Instant.now().toString());
            while (System.currentTimeMillis() < runtime) {

            List<IFabricWritePayload> iFabricWritePayloads = prepareWritePayloads(clientObject, listOfWorkloadObjects);

            Write fabricWrite = new Write();
            write(clientObject, workloadId, prepareWorkloadObject, iFabricWritePayloads, fabricWrite);
                Listener.getExternalTotalCounter().incrementAndGet();
            }
            LOG.info("Client: " + clientObject.getClientId() + " workload: " + workloadId + " end time: " + Instant.now().toString());
            if (finishedCounter.incrementAndGet() == GeneralConfiguration.CLIENT_COUNT * GeneralConfiguration.CLIENT_WORKLOADS.get(0)) {
                LOG.info("Finished all workloads");
                Listener.getExternalFinished().set(true);
            }
        }

        // awaitEndOfExecution(prepareWorkloadObject);

        // unregisterListeners(clientObject, prepareWorkloadObject);

        return null;
    }

    private static volatile RateLimiter rateLimiter = Configuration.ENABLE_RATE_LIMITER_FOR_WRITE_PAYLOADS ?
            RateLimiter.create(
                    GenericSelectionStrategy.selectFixed(
                            Configuration.WRITE_PAYLOADS_PER_SECOND,
                            Collections.singletonList(0), false).get(0)
            ) : null;

    @Suspendable
    private void write(final ClientObject clientObject, final int workloadId,
                       final PrepareFabricWorkloadObject prepareWorkloadObject,
                       final List<IFabricWritePayload> iFabricWritePayloads, final Write fabricWrite) {
        prepareExpectedEventMap(clientObject, iFabricWritePayloads);

        /*RateLimiter rateLimiter = Configuration.ENABLE_RATE_LIMITER_FOR_WRITE_PAYLOADS ?
                RateLimiter.create(
                        GenericSelectionStrategy.selectFixed(
                                Configuration.WRITE_PAYLOADS_PER_SECOND,
                                Collections.singletonList(0), false).get(0)
                ) : null;*/

        for (final IFabricWritePayload iFabricWritePayload : iFabricWritePayloads) {

            TransactionProposalRequest transactionRequest =
                    iFabricWritePayload.getTransactionRequest(prepareWorkloadObject.getFabricClient());

            Listener.getObtainedEventsMap().get(clientObject.getClientId()).get(iFabricWritePayload.getEventPrefix() + iFabricWritePayload.getSignature()).setLeft(System.nanoTime());

            Map<String, MutablePair<Long, Long>> stringMutablePairMap =
                    ListenerReferenceValues.getTimeMap().computeIfAbsent(clientObject.getClientId(),
                            c -> new ConcurrentHashMap<>());
            stringMutablePairMap.computeIfAbsent(iFabricWritePayload.getEventPrefix() + iFabricWritePayload.getSignature(), m ->
                    MutablePair.of(System.currentTimeMillis(), -1L));

            //handleRequestDistribution(clientObject.getClientId());

            WriteStatisticObject writeStatisticObject = new WriteStatisticObject();
            CustomStatisticObject<String> customStatisticObject = new CustomStatisticObject<>();

            writeStatisticObject.getAssocEventList().add(iFabricWritePayload.getEventPrefix() + iFabricWritePayload.getSignature());

            writeStatisticObject.setCurrentTimeStart(System.currentTimeMillis());
            writeStatisticObject.setRequestNumber(++writeRequests);
            writeStatisticObject.setClientId(clientObject.getClientId());
            writeStatisticObject.setRequestId("clid-" + clientObject.getClientId() + "-write-" + writeRequests +
                    "-wlid" +
                    "-" + workloadId);

            write(prepareWorkloadObject, fabricWrite, transactionRequest,
                    writeStatisticObject, iFabricWritePayload, clientObject, customStatisticObject);
            writeStatisticObject.setCurrentTimeEnd(System.currentTimeMillis());
            writeStatisticObject.getSpecificPayloadTypeList().add(iFabricWritePayload.getSpecificPayloadType());
            iStatistics.add(writeStatisticObject);
            iStatistics.add(customStatisticObject);

        }
    }

    @Suspendable
    private void write(final PrepareFabricWorkloadObject prepareWorkloadObject, final Write fabricWrite,
                       final TransactionProposalRequest transactionRequest,
                       final WriteStatisticObject writeStatisticObject, final IFabricWritePayload iFabricWritePayload
            , final ClientObject clientObject, final CustomStatisticObject<String> customStatisticObject) {

        boolean hasError;
        String hasMessage;
        int e = 0;
        boolean timeSet = false;
        int retries = Configuration.RESEND_TIMES_UPON_ERROR_WRITE;
        do {

            if(IS_STOPPED.get()) {
                rateLimiter.acquire();
            }

            if (Configuration.ENABLE_RATE_LIMITER_FOR_WRITE_PAYLOADS) {
                rateLimiter.acquire();
                if (GeneralConfiguration.NOTE_RATE_LIMITER_WRITE == client.statistics.WriteStatisticObject.NoteRateLimiter.YES) {
                    if (!timeSet) {
                        writeStatisticObject.setCurrentTimeStart(System.currentTimeMillis());

                        Listener.getObtainedEventsMap().get(clientObject.getClientId()).get(iFabricWritePayload.getEventPrefix() + iFabricWritePayload.getSignature()).setLeft(System.nanoTime());

                        Map<String, MutablePair<Long, Long>> stringMutablePairMap =
                                ListenerReferenceValues.getTimeMap().computeIfAbsent(clientObject.getClientId(),
                                        c -> new ConcurrentHashMap<>());
                        stringMutablePairMap.computeIfAbsent(iFabricWritePayload.getEventPrefix() + iFabricWritePayload.getSignature(), m ->
                                MutablePair.of(System.currentTimeMillis(), -1L));
                        timeSet = true;
                    }
                }
            }

            ImmutablePair<Boolean, String> write = fabricWrite.write(transactionRequest,
                    prepareWorkloadObject.getFabricClient().getInstance().getUserContext(),
                    prepareWorkloadObject.getChannel(), writeStatisticObject, prepareWorkloadObject.getPeerList(),
                    prepareWorkloadObject.getOrdererList(), customStatisticObject);

            hasError = write.getLeft();
            hasMessage = write.getRight();

            if (hasError) {
                LOG.error("Had error (write) resend " + e + " message " + hasMessage);
                e++;
            }

            if (hasError && hasMessage != null) {
                writeStatisticObject.getErrorMessages().add(hasMessage);
            }

            if (Configuration.DROP_ON_TIMEOUT && write.getRight().contains("TIMEOUT_EX")) {
                LOG.error("Dropping write request due to exception " + write.getRight());
                break;
            }

        } while (hasError && e < retries);
        LOG.info("Number of resends (write): " + e);

        if (hasError) {
            writeStatisticObject.setFailedRequest(true);
        }
    }

    @Suspendable
    private void prepareExpectedEventMap(final ClientObject clientObject,
                                         final List<IFabricWritePayload> iFabricWritePayloads) {

        for (final IFabricWritePayload iFabricWritePayload : iFabricWritePayloads) {

            String expectedEvent = iFabricWritePayload.getEventPrefix() + iFabricWritePayload.getSignature();

            Map<String, MutablePair<Long, Long>> stringMutablePairMap =
                    Listener.getObtainedEventsMap().computeIfAbsent(clientObject.getClientId(),
                            c -> new ConcurrentHashMap<>());
            stringMutablePairMap.computeIfAbsent(expectedEvent, m ->
                    MutablePair.of(System.nanoTime(), -1L));

        }
    }

    @Suspendable
    private static synchronized void unregisterListeners(final ClientObject clientObject,
                                                         final PrepareFabricWorkloadObject prepareWorkloadObject) {
        if (Configuration.UNREGISTER_LISTENERS) {
            for (final Map.Entry<String, Boolean> listenerEntry : prepareWorkloadObject.getListener().entrySet()) {
                Listener.unregisterAndUnsetAll(listenerEntry.getKey(), listenerEntry.getValue(),
                        prepareWorkloadObject.getChannel());
            }

            LOG.info("Closed listeners, finished " + clientObject.getClientId());
        }
    }

    @Suspendable
    private void awaitEndOfExecution(final PrepareFabricWorkloadObject prepareWorkloadObject) {
        for (final IListenerDisconnectionLogic iListenerDisconnectionLogic :
                prepareWorkloadObject.getIListenerDisconnectionLogicList()) {
            try {
                iListenerDisconnectionLogic.isDone().get(Configuration.TIMEOUT_LISTENER,
                        Configuration.TIMEOUT_LISTENER_TIME_UNIT);
                iStatistics.addAll(iListenerDisconnectionLogic.getStatistics());
            } catch (InterruptedException | ExecutionException | TimeoutException ex) {
                ExceptionHandler.logException(ex);
            }
        }
    }

    @Suspendable
    private List<IFabricWritePayload> prepareWritePayloads(final ClientObject clientObject,
                                                           final List<PrepareFabricWorkloadObject> listOfWorkloadObjects) {
        List<IFabricWritePayload> iFabricWritePayloads;

            IFabricPayloads iFabricWritePayloadPattern = null;
            try {
                iFabricWritePayloadPattern = Configuration.WRITE_PAYLOAD_PATTERN.getDeclaredConstructor().newInstance();
            } catch (InstantiationException | IllegalAccessException | InvocationTargetException | NoSuchMethodException ex) {
                ExceptionHandler.logException(ex);
            }

            iFabricWritePayloads =
                    (List<IFabricWritePayload>) iFabricWritePayloadPattern.getPayloads(clientObject,
                            Configuration.NUMBER_OF_TRANSACTIONS_PER_CLIENT);
        return iFabricWritePayloads;
    }

    @Suspendable
    private void addToExpectedEventMap(final ClientObject clientObject,
                                       final String signature,
                                       final String expectedEventPrefix) {

        String expectedEvent = expectedEventPrefix + signature;

        Map<String, MutablePair<Long, Long>> stringMutablePairMap =
                Listener.getObtainedEventsMap().computeIfAbsent(clientObject.getClientId(),
                        c -> new ConcurrentHashMap<>());
        stringMutablePairMap.computeIfAbsent(expectedEvent, m ->
                MutablePair.of(System.nanoTime(), -1L));

    }

    @SafeVarargs
    @Override
    @Suspendable
    public final <E> E endWorkload(final E... params) {
        LOG.info(((ClientObject) params[1]).getClientId() + " client ended");
        return null;
    }

    @SafeVarargs
    @Override
    @Suspendable
    public synchronized final <E> Queue<IStatistics> getStatistics(final E... params) {
        return iStatistics;
    }

    @SafeVarargs
    @Override
    @Suspendable
    public final <E> E stopWorkload(final E... params) {
        double rateLimiterVal = 0.0000000000000000000000000000001;
        if(rateLimiter == null) {
            rateLimiter = RateLimiter.create(rateLimiterVal);
            IS_STOPPED.set(true);
            LOG.warn("Stopped workload - created rate limiter");
        } else {
            rateLimiter.setRate(rateLimiterVal);
            IS_STOPPED.set(true);
            LOG.warn("Stopped workload - set rate limiter");
        }
        return null;
    }

    @SafeVarargs
    @Override
    @Suspendable
    public final <E> void handleRequestDistribution(final E... params) {
        try {
            int randomSleep = NumberGenerator.selectRandomAsInt(50, 250);
            LOG.debug("Sleep time: " + randomSleep + " for " + params[0]);
            Strand.sleep(randomSleep);
        } catch (SuspendExecution | InterruptedException ex) {
            ExceptionHandler.logException(ex);
        }
    }
}
