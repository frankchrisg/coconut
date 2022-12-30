package quorum.workloads;

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
import io.reactivex.disposables.Disposable;
import org.apache.commons.lang3.tuple.ImmutablePair;
import org.apache.commons.lang3.tuple.MutablePair;
import org.apache.log4j.Logger;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.core.DefaultBlockParameterName;
import org.web3j.protocol.core.Request;
import org.web3j.protocol.core.methods.response.EthGetTransactionCount;
import org.web3j.protocol.websocket.WebSocketService;
import quorum.configuration.Configuration;
import quorum.connection.Websocket;
import quorum.listener.Listener;
import quorum.listener.ListenerHelper;
import quorum.payload_patterns.IQuorumPayloads;
import quorum.payloads.IQuorumWritePayload;
import quorum.statistics.CustomStatisticObject;
import quorum.statistics.WriteStatisticObject;
import quorum.write.WriteNonRawTransaction;
import quorum.write.WriteRawTransaction;

import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.math.BigInteger;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.Instant;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeoutException;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicLong;

public class ExecuteQuorumWorkloadTimeFrame implements IExecuteWorkload, IRequestDistribution {

    private static final Logger LOG = Logger.getLogger(ExecuteQuorumWorkloadTimeFrame.class);

    private static final Map<String, AtomicInteger> SUCCESSFUL_WRITE_REQUESTS =
            new ConcurrentHashMap<>();
    private static final Map<String, AtomicInteger> UNSUCCESSFUL_WRITE_REQUESTS =
            new ConcurrentHashMap<>();
    private static final int CLOSED_VALUE = -1;
    private static final String WRITE_SUFFIX = "-write";
    private final Queue<IStatistics> iStatistics = new ConcurrentLinkedQueue<>();
    private int writeRequests;
    private Web3j web3jToShutdownWrite;
    private WebSocketService webSocketServiceToCloseWrite;
    private static final AtomicBoolean IS_STOPPED = new AtomicBoolean(false);

    private static final Map<String, AtomicInteger> FINISHED_WRITE_REQUESTS = new ConcurrentHashMap<>();

    private static final AtomicInteger finishedCounter = new AtomicInteger(0);

    @SafeVarargs
    @Suspendable
    @Override
    public final <E> E executeWorkload(final E... params) {

        ClientObject clientObject = (ClientObject) params[1];
        int workloadId = Integer.parseInt(String.valueOf(params[2])) + 1;

        List<PrepareQuorumWorkloadObject> listOfWorkloadObjects =
                GenericSelectionStrategy.selectFixed(((ArrayList<PrepareQuorumWorkloadObject>) params[0]),
                        Collections.singletonList(0), false);
        PrepareQuorumWorkloadObject prepareWorkloadObject = listOfWorkloadObjects.get(0);

        if (Configuration.SEND_WRITE_REQUESTS) {
            long startTime = System.currentTimeMillis();
            long maxDurationInMilliseconds = Configuration.RUNTIME;
            long runtime = startTime + maxDurationInMilliseconds;
            LOG.info("Client: " + clientObject.getClientId() + " workload: " + workloadId + " start time: " + Instant.now().toString());
            while (System.currentTimeMillis() < runtime) {
            List<IQuorumWritePayload> iQuorumWritePayloads = prepareWritePayloads(clientObject, listOfWorkloadObjects);

            prepareExpectedEventMap(clientObject, iQuorumWritePayloads);

            write(clientObject, prepareWorkloadObject, iQuorumWritePayloads, workloadId);
                Listener.getExternalTotalCounter().incrementAndGet();
            }
            AtomicInteger finishedWriteReqeust = FINISHED_WRITE_REQUESTS.computeIfAbsent(clientObject.getClientId(),
                    a -> new AtomicInteger(0));
            finishedWriteReqeust.incrementAndGet();

            LOG.info("Client: " + clientObject.getClientId() + " workload: " + workloadId + " end time: " + Instant.now().toString());
            if (finishedCounter.incrementAndGet() == GeneralConfiguration.CLIENT_COUNT * GeneralConfiguration.CLIENT_WORKLOADS.get(0)) {
                LOG.info("Finished all workloads");
                Listener.getExternalFinished().set(true);
            }
        }

        // awaitEndOfExecution(prepareWorkloadObject);

        // unregisterListeners(clientObject, prepareWorkloadObject);

        try {
            Websocket websocket = new Websocket();
            String address = prepareWorkloadObject.getNodeAddress();
            WebSocketService webSocketService = websocket.prepareWebsocket(address);
            Web3j web3j = Objects.requireNonNull(websocket).prepareWeb3j(webSocketService);
            Request<?, EthGetTransactionCount> ethGetPendingTransactionCountReq =
                    web3j.ethGetTransactionCount(prepareWorkloadObject.getFromAddress(),
                            DefaultBlockParameterName.PENDING);
            EthGetTransactionCount ethGetPendingTransactionCount = ethGetPendingTransactionCountReq.send();
            CustomStatisticObject<String> customStatisticObject = new CustomStatisticObject<>();
            BigInteger pendingTransactionCount = ethGetPendingTransactionCount.getTransactionCount();
            customStatisticObject.setSharedId("pending_txs_quorum");
            customStatisticObject.setId(clientObject.getClientId() + "-" + workloadId);
            customStatisticObject.setValue(pendingTransactionCount);
            iStatistics.add(customStatisticObject);
        } catch (IOException ex) {
            LOG.error("Failure while getting pending transactions" + ex.getMessage());
        }

        return null;
    }

    private static volatile RateLimiter rateLimiter = Configuration.ENABLE_RATE_LIMITER_FOR_WRITE_PAYLOADS ?
            RateLimiter.create(
                    GenericSelectionStrategy.selectFixed(
                            Configuration.WRITE_PAYLOADS_PER_SECOND, Collections.singletonList(0), false).get(0)
            ) : null;

    @Suspendable
    private void write(final ClientObject clientObject, final PrepareQuorumWorkloadObject prepareWorkloadObject,
                       final List<IQuorumWritePayload> iQuorumWritePayloads,
                       final int workloadId) {

        /*RateLimiter rateLimiter = Configuration.ENABLE_RATE_LIMITER_FOR_WRITE_PAYLOADS ?
                RateLimiter.create(
                        GenericSelectionStrategy.selectFixed(
                                Configuration.WRITE_PAYLOADS_PER_SECOND, Collections.singletonList(0), false).get(0)
                ) : null;*/

        for (final IQuorumWritePayload iQuorumWritePayload : iQuorumWritePayloads) {

            WriteRawTransaction writeRawTransaction = null;
            WriteNonRawTransaction writeNonRawTransaction = null;
            if (Configuration.SEND_RAW) {
                writeRawTransaction = new WriteRawTransaction();
            } else {
                writeNonRawTransaction = new WriteNonRawTransaction();
            }

            WebSocketService webSocketService;
            Web3j web3j;

            Websocket websocket = null;
            if ((!Configuration.USE_PREPARED_WEBSOCKET_SERVICE_WRITE || !Configuration.USE_PREPARED_WEB3J_WRITE)) {
                websocket = new Websocket();
            }
            if (Configuration.USE_PREPARED_WEBSOCKET_SERVICE_WRITE) {
                webSocketService = prepareWorkloadObject.getWebSocketServiceWrite();
                webSocketServiceToCloseWrite = webSocketService;
            } else {
                String address = prepareWorkloadObject.getNodeAddress();
                // String address = "http://192.168.2.103:40202";
                webSocketService = websocket.prepareWebsocket(address);
            }
            if (Configuration.USE_PREPARED_WEB3J_WRITE) {
                web3j = prepareWorkloadObject.getWeb3jWrite();
                web3jToShutdownWrite = web3j;
            } else {
                web3j = Objects.requireNonNull(websocket).prepareWeb3j(webSocketService);
            }

            String[] eventArray = new String[2];
            eventArray[0] = iQuorumWritePayload.getEventPrefix();
            eventArray[1] = iQuorumWritePayload.getSignature();

            ListenerHelper.getObtainedEventsMap().get(clientObject.getClientId()).get(Arrays.toString(eventArray)).setLeft(System.nanoTime());

            Map<String, MutablePair<Long, Long>> stringMutablePairMap =
                    ListenerReferenceValues.getTimeMap().computeIfAbsent(clientObject.getClientId(),
                            c -> new ConcurrentHashMap<>());
            stringMutablePairMap.computeIfAbsent(Arrays.toString(eventArray), m ->
                    MutablePair.of(System.currentTimeMillis(), -1L));

            //handleRequestDistribution(clientObject.getClientId());

            WriteStatisticObject writeStatisticObject = new WriteStatisticObject();
            CustomStatisticObject<String> customStatisticObject = new CustomStatisticObject<>();

            writeStatisticObject.getAssocEventList().add(Arrays.toString(eventArray));

            writeStatisticObject.setCurrentTimeStart(System.currentTimeMillis());
            writeStatisticObject.setRequestNumber(++writeRequests);
            writeStatisticObject.setClientId(clientObject.getClientId());
            writeStatisticObject.setRequestId("clid-" + clientObject.getClientId() + "-write-" + writeRequests +
                    "-wlid" +
                    "-" + workloadId);

            write(prepareWorkloadObject, iQuorumWritePayload, writeRawTransaction, writeNonRawTransaction,
                    writeStatisticObject, web3j, clientObject, customStatisticObject);
            writeStatisticObject.setCurrentTimeEnd(System.currentTimeMillis());
            writeStatisticObject.getSpecificPayloadTypeList().add(iQuorumWritePayload.getSpecificPayloadType());

            writeStatisticObject.getParticipatingServers().add(Objects.requireNonNull(websocket).getAddress());

            iStatistics.add(writeStatisticObject);
            iStatistics.add(customStatisticObject);

            if (!Configuration.USE_PREPARED_WEBSOCKET_SERVICE_WRITE) {
                webSocketService.close();
            }
            if (!Configuration.USE_PREPARED_WEB3J_WRITE) {
                web3j.shutdown();
            }

        }
    }

    @Suspendable
    private void write(final PrepareQuorumWorkloadObject prepareWorkloadObject,
                       final IQuorumWritePayload iQuorumWritePayload, final WriteRawTransaction writeRawTransaction,
                       final WriteNonRawTransaction writeNonRawTransaction,
                       final WriteStatisticObject writeStatisticObject, final Web3j web3j,
                       final ClientObject clientObject, final CustomStatisticObject<String> customStatisticObject) {

        boolean hasError = true;
        String hasMessage;
        int e = 0;
        boolean timeSet = false;
        int retries = Configuration.RESEND_TIMES_UPON_ERROR_WRITE;
        do {
            ImmutablePair<Boolean, String> writeRes;

            if(IS_STOPPED.get()) {
                rateLimiter.acquire();
            }

            if (Configuration.ENABLE_RATE_LIMITER_FOR_WRITE_PAYLOADS) {
                rateLimiter.acquire();
                if (GeneralConfiguration.NOTE_RATE_LIMITER_WRITE == client.statistics.WriteStatisticObject.NoteRateLimiter.YES) {
                    if (!timeSet) {
                        writeStatisticObject.setCurrentTimeStart(System.currentTimeMillis());

                        String[] eventArray = new String[2];
                        eventArray[0] = iQuorumWritePayload.getEventPrefix();
                        eventArray[1] = iQuorumWritePayload.getSignature();

                        ListenerHelper.getObtainedEventsMap().get(clientObject.getClientId()).get(Arrays.toString(eventArray)).setLeft(System.nanoTime());

                        Map<String, MutablePair<Long, Long>> stringMutablePairMap =
                                ListenerReferenceValues.getTimeMap().computeIfAbsent(clientObject.getClientId(),
                                        c -> new ConcurrentHashMap<>());
                        stringMutablePairMap.computeIfAbsent(Arrays.toString(eventArray), m ->
                                MutablePair.of(System.currentTimeMillis(), -1L));

                        timeSet = true;
                    }
                }
            }

            AtomicLong nonce = null;
            if (Configuration.DISTRIBUTED_NONCE_HANDLING) {
                try (java.sql.Connection connection = client.database.Connection.getConnection()) {

                    String query = "UPDATE quorum_nonce AS qn SET nonce = qn.nonce + 1 " +
                            "WHERE address ='" + prepareWorkloadObject.getFromAddress() + "' " +
                            "RETURNING nonce";

                    if (connection == null) {
                        try {
                            Strand.sleep(Configuration.DATABASE_SLEEP_TIME);
                            continue;
                        } catch (SuspendExecution | InterruptedException exSleep) {
                            ExceptionHandler.logException(exSleep);
                            continue;
                        }
                    }
                    PreparedStatement preparedStatement = connection.prepareStatement(query);
                    ResultSet resultSet = preparedStatement.executeQuery();

                    while (resultSet.next()) {
                        LOG.info("New nonce: " + (resultSet.getInt("nonce") - 1));
                        nonce = new AtomicLong(resultSet.getInt("nonce") - 1);
                    }

                    resultSet.close();
                    preparedStatement.close();
                } catch (SQLException ex) {
                    try {
                        Strand.sleep(Configuration.DATABASE_SLEEP_TIME);
                        continue;
                    } catch (SuspendExecution | InterruptedException exSleep) {
                        ExceptionHandler.logException(exSleep);
                        continue;
                    }
                }
            } else {
                nonce = prepareWorkloadObject.getNonce();
            }

            if (Configuration.SEND_RAW) {
                writeRes = writeRawTransaction.write(iQuorumWritePayload, web3j,
                        prepareWorkloadObject.getCredentials(),
                        prepareWorkloadObject.getFromAddress(), prepareWorkloadObject.getToAddress(),
                        nonce, writeStatisticObject);
            } else {

                /*if(HelperMaps.getUnlockedMap().putIfAbsent(Helper.getIpMap().get("http://192.168.2.103:40202").get
                (0).getLeft(), true) != null) {
                    LOG.info("Unlock map entry already existing");
                } else {
                    Helper.unlock(webSocketServiceToCloseWrite, Helper.getIpMap().get("http://192.168.2.103:40202")
                    .get(0).getLeft(), Helper.getIpMap().get("http://192.168.2.103:40202").get(0).getRight());
                    nonce = Helper.setNonceFor(web3j, Helper.getIpMap().get("http://192.168.2.103:40202").get(0)
                    .getLeft());
                    LOG.info("Unlock map entry not existing");
                }
                if(HelperMaps.getNonceMap().putIfAbsent(Helper.getIpMap().get("http://192.168.2.103:40202").get(0)
                .getLeft(), nonce) != null) {
                    nonce =  new AtomicLong(HelperMaps.getNonceMap().get(Helper.getIpMap().get("http://192.168.2
                    .103:40202").get(0).getLeft()).getAndIncrement());
                    LOG.info("Nonce map entry already existing");
                } else {
                    LOG.info("Nonce map entry not existing");
                }*/

                writeRes = writeNonRawTransaction.write(iQuorumWritePayload, web3j,
                        prepareWorkloadObject.getFromAddress(), prepareWorkloadObject.getToAddress(),
                        nonce, writeStatisticObject, customStatisticObject);
            }

            hasError = writeRes.getLeft();
            hasMessage = writeRes.getRight();

            if (hasError) {
                LOG.error("Had error (write) resend " + e + " message " + hasMessage);
                e++;
            } else {
                if (Configuration.USE_PREPARED_WEBSOCKET_SERVICE_WRITE || Configuration.USE_PREPARED_WEB3J_WRITE) {
                    if (SUCCESSFUL_WRITE_REQUESTS.putIfAbsent(clientObject.getClientId(), new AtomicInteger(1)) != null) {
                        SUCCESSFUL_WRITE_REQUESTS.get(clientObject.getClientId()).incrementAndGet();
                    }
                }
            }

            if (hasError && hasMessage != null) {
                writeStatisticObject.getErrorMessages().add(hasMessage);
            }

            if (Configuration.DROP_ON_TIMEOUT && writeRes.getRight().contains("TIMEOUT_EX")) {
                LOG.error("Dropping write request due to exception " + writeRes.getRight());
                break;
            }

        } while (hasError && e < retries);

        if (hasError) {
            if (Configuration.USE_PREPARED_WEBSOCKET_SERVICE_WRITE || Configuration.USE_PREPARED_WEB3J_WRITE) {
                if (UNSUCCESSFUL_WRITE_REQUESTS.putIfAbsent(clientObject.getClientId(), new AtomicInteger(1)) != null) {
                    UNSUCCESSFUL_WRITE_REQUESTS.get(clientObject.getClientId()).incrementAndGet();
                }
            }
        }

        LOG.info("Number of resends (write): " + e);

        if (hasError) {
            writeStatisticObject.setFailedRequest(true);
        }
    }

    @Suspendable
    private static synchronized void unregisterListeners(final ClientObject clientObject,
                                                         final PrepareQuorumWorkloadObject prepareWorkloadObject) {
        if (Configuration.UNREGISTER_LISTENERS) {
            for (final Disposable listener : prepareWorkloadObject.getListener()) {
                Listener.unregisterListener(listener);
            }
            LOG.info("Closed listeners, finished " + clientObject.getClientId());
        }
    }

    @Suspendable
    private void awaitEndOfExecution(final PrepareQuorumWorkloadObject prepareWorkloadObject) {
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
    private List<IQuorumWritePayload> prepareWritePayloads(final ClientObject clientObject,
                                                           final List<PrepareQuorumWorkloadObject> listOfWorkloadObjects) {
        List<IQuorumWritePayload> iQuorumWritePayloads;

        IQuorumPayloads iQuorumWritePayloadPattern = null;
        try {
            iQuorumWritePayloadPattern = Configuration.WRITE_PAYLOAD_PATTERN.getDeclaredConstructor().newInstance();
        } catch (InstantiationException | IllegalAccessException | InvocationTargetException | NoSuchMethodException ex) {
            ExceptionHandler.logException(ex);
        }

        iQuorumWritePayloads =
                (List<IQuorumWritePayload>) Objects.requireNonNull(iQuorumWritePayloadPattern).getPayloads(clientObject,
                        Configuration.NUMBER_OF_TRANSACTIONS_PER_CLIENT);
        return iQuorumWritePayloads;
    }

    @Suspendable
    private void prepareExpectedEventMap(final ClientObject clientObject,
                                         final List<IQuorumWritePayload> iQuorumWritePayloads) {

        for (final IQuorumWritePayload iQuorumWritePayload : iQuorumWritePayloads) {

            String[] eventArray = new String[2];
            eventArray[0] = iQuorumWritePayload.getEventPrefix();
            eventArray[1] = iQuorumWritePayload.getSignature();

            Map<String, MutablePair<Long, Long>> stringMutablePairMap =
                    ListenerHelper.getObtainedEventsMap().computeIfAbsent(clientObject.getClientId(),
                            c -> new ConcurrentHashMap<>());
            stringMutablePairMap.computeIfAbsent(Arrays.toString(eventArray), m ->
                    MutablePair.of(System.nanoTime(), -1L));

        }
    }

    @Suspendable
    private void addToExpectedEventMap(final ClientObject clientObject,
                                       final String signature,
                                       final String expectedEventPrefix) {

        String[] eventArray = new String[2];
        eventArray[0] = expectedEventPrefix;
        eventArray[1] = signature;

        Map<String, MutablePair<Long, Long>> stringMutablePairMap =
                ListenerHelper.getObtainedEventsMap().computeIfAbsent(clientObject.getClientId(),
                        c -> new ConcurrentHashMap<>());
        stringMutablePairMap.computeIfAbsent(Arrays.toString(eventArray), m ->
                MutablePair.of(System.nanoTime(), -1L));

    }

    @SafeVarargs
    @Override
    @Suspendable
    public final <E> E endWorkload(final E... params) {
        ClientObject clientObject = (ClientObject) params[1];

        LOG.info(clientObject.getClientId() + " client ended");

        if (Configuration.USE_PREPARED_WEBSOCKET_SERVICE_WRITE || Configuration.USE_PREPARED_WEB3J_WRITE) {
            /*synchronized (SUCCESSFUL_WRITE_REQUESTS) {
                synchronized (UNSUCCESSFUL_WRITE_REQUESTS) {

                    boolean successfulWrite = SUCCESSFUL_WRITE_REQUESTS.get(clientObject.getClientId()) == null;
                    boolean unsuccessfulWrite = UNSUCCESSFUL_WRITE_REQUESTS.get(clientObject.getClientId()) == null;

                    if ((
                            (successfulWrite ? 0 :
                                    SUCCESSFUL_WRITE_REQUESTS.get(clientObject.getClientId()).get())
                                    +
                                    (unsuccessfulWrite ? 0 :
                                            UNSUCCESSFUL_WRITE_REQUESTS.get(clientObject.getClientId()).get()))
                            == Configuration.NUMBER_OF_TRANSACTIONS_PER_CLIENT * GenericSelectionStrategy.selectFixed(GeneralConfiguration.CLIENT_WORKLOADS, Collections.singletonList(0), false).get(0)) {*/
                      if(FINISHED_WRITE_REQUESTS.get(clientObject.getClientId()).get() == GenericSelectionStrategy.selectFixed(GeneralConfiguration.CLIENT_WORKLOADS, Collections.singletonList(0), false).get(0)) {
                          if (Configuration.USE_PREPARED_WEBSOCKET_SERVICE_WRITE) {
                              webSocketServiceToCloseWrite.close();
                          }
                          if (Configuration.USE_PREPARED_WEB3J_WRITE) {
                              web3jToShutdownWrite.shutdown();
                          }
                        /*if (!successfulWrite) {
                            SUCCESSFUL_WRITE_REQUESTS.get(clientObject.getClientId()).set(CLOSED_VALUE);
                        }
                        if (!unsuccessfulWrite) {
                            UNSUCCESSFUL_WRITE_REQUESTS.get(clientObject.getClientId()).set(CLOSED_VALUE);
                        }*/
                          LOG.info("Shutdown of connections for: " + clientObject.getClientId());
            }
        }

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
