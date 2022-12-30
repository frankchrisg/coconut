package diem.workloads;

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
import com.diem.DiemClient;
import com.diem.DiemException;
import com.diem.Ed25519PrivateKey;
import com.diem.types.SignedTransaction;
import com.diem.utils.AccountAddressUtils;
import com.diem.utils.HashUtils;
import com.google.common.util.concurrent.RateLimiter;
import diem.configuration.Configuration;
import diem.connection.Client;
import diem.helper.AccountInformation;
import diem.helper.AccountStore;
import diem.helper.Helper;
import diem.helper.PayloadHelper;
import diem.listener.Listener;
import diem.payload_patterns.IDiemPayloads;
import diem.payloads.IDiemReadPayload;
import diem.payloads.IDiemWritePayload;
import diem.read.Read;
import diem.statistics.CustomStatisticObject;
import diem.statistics.ReadStatisticObject;
import diem.statistics.WriteStatisticObject;
import diem.write.Write;
import org.apache.commons.lang3.tuple.ImmutablePair;
import org.apache.commons.lang3.tuple.MutablePair;
import org.apache.log4j.Logger;

import java.lang.reflect.InvocationTargetException;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeoutException;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicLong;

public class ExecuteDiemWorkload implements IExecuteWorkload, IRequestDistribution {

    private static final Logger LOG = Logger.getLogger(ExecuteDiemWorkload.class);
    private static final String READ_SUFFIX = "-read";
    private static final String WRITE_SUFFIX = "-write";
    private final Queue<IStatistics> iStatistics = new ConcurrentLinkedQueue<>();
    private int writeRequests;
    private int readRequests;
    private static final Map<String, AtomicInteger> ACCOUNT_COUNTER = new ConcurrentHashMap<>();
    private static final Map<String, AtomicLong> NONCE_MAP = new ConcurrentHashMap<>();
    private static final AtomicBoolean IS_STOPPED = new AtomicBoolean(false);

    @SafeVarargs
    @Override
    @Suspendable
    public final <E> E executeWorkload(final E... params) {

        ClientObject clientObject = (ClientObject) params[1];

        int workloadId = Integer.parseInt(String.valueOf(params[2])) + 1;

        List<PrepareDiemWorkloadObject> listOfWorkloadObjects =
                GenericSelectionStrategy.selectFixed(((ArrayList<PrepareDiemWorkloadObject>) params[0]),
                        Collections.singletonList(0), false);
        PrepareDiemWorkloadObject prepareWorkloadObject = listOfWorkloadObjects.get(0);

        ACCOUNT_COUNTER.computeIfAbsent("wl-" + workloadId + "-cl-" + clientObject.getClientId(),
                c -> new AtomicInteger(0));

        DiemClient diemClient = getDiemClient(prepareWorkloadObject);

        Map<String, List<AccountInformation>> accountInformationMap = prepareWorkloadObject.getAccountInformationMap();

        if (Configuration.SEND_WRITE_REQUESTS) {
            List<IDiemWritePayload> iDiemWritePayloads = prepareWritePayloads(clientObject, listOfWorkloadObjects);

            Write diemWrite = new Write();
            write(clientObject, workloadId, prepareWorkloadObject, iDiemWritePayloads, diemWrite, diemClient,
                    accountInformationMap);
        }

        if (Configuration.SEND_READ_REQUESTS) {
            List<IDiemReadPayload> iDiemReadPayloads = prepareReadPayloads(clientObject, listOfWorkloadObjects);

            Read read = new Read();
            read(prepareWorkloadObject, clientObject, iDiemReadPayloads, read, workloadId);
        }

        // awaitEndOfExecution(prepareWorkloadObject);

        // unregisterListeners(clientObject, prepareWorkloadObject);

        return null;
    }

    @Suspendable
    private DiemClient getDiemClient(final PrepareDiemWorkloadObject prepareWorkloadObject) {
        DiemClient client;
        if (!Configuration.PREPARE_CLIENT_CONNECTION) {
            client = new Client().createClient(Configuration.CONNECTION_RETRIES,
                    Configuration.WAIT_DURATION_MILLISECONDS,
                    Configuration.KEEP_ALIVE_TIME,
                    GenericSelectionStrategy.selectFixed(Configuration.NODE_LIST,
                            Collections.singletonList(Integer.parseInt(GeneralConfiguration.HOST_ID.split("-")[2])),
                            true).get(0),
                    Configuration.CHAIN_ID
            );
        } else {
            client = prepareWorkloadObject.getDiemClient();
        }
        return client;
    }

    private static volatile RateLimiter rateLimiter = Configuration.ENABLE_RATE_LIMITER_FOR_WRITE_PAYLOADS ?
            RateLimiter.create(
                    GenericSelectionStrategy.selectFixed(
                            Configuration.WRITE_PAYLOADS_PER_SECOND,
                            Collections.singletonList(0), false).get(0)
            ) : null;

    @Suspendable
    private void write(final ClientObject clientObject, final int workloadId,
                       final PrepareDiemWorkloadObject prepareWorkloadObject,
                       final List<IDiemWritePayload> iDiemWritePayloads, final Write diemWrite,
                       final DiemClient diemClient, final Map<String,
            List<AccountInformation>> accountInformationMap) {
        prepareExpectedEventMap(clientObject, iDiemWritePayloads);

        /*RateLimiter rateLimiter = Configuration.ENABLE_RATE_LIMITER_FOR_WRITE_PAYLOADS ?
                RateLimiter.create(
                        GenericSelectionStrategy.selectFixed(
                                Configuration.WRITE_PAYLOADS_PER_SECOND,
                                Collections.singletonList(0), false).get(0)
                ) : null;*/

        AccountInformation accountInformation = null;
        AtomicLong startSequenceNumber = new AtomicLong(0);
        if (!Configuration.CREATE_ACCOUNT_PER_TRANSACTION && !Configuration.SINGLE_ACCOUNT_FOR_WORKLOAD) {
            accountInformation = accountInformationMap.get("wl-" + 1).get(0);
            startSequenceNumber = new AtomicLong(
                    Configuration.DISTRIBUTED_NONCE_HANDLING ?
                            getStartNoncePlain(diemClient, accountInformation.getAccountAddress()) :
                            getStartNonce(diemClient, accountInformation.getAccountAddress())
            );
        }
        if (!Configuration.CREATE_ACCOUNT_PER_TRANSACTION && Configuration.SINGLE_ACCOUNT_FOR_WORKLOAD) {
            accountInformation = accountInformationMap.get("wl-" + workloadId).get(0);
            startSequenceNumber = new AtomicLong(
                    Configuration.DISTRIBUTED_NONCE_HANDLING ?
                            getStartNoncePlain(diemClient, accountInformation.getAccountAddress()) :
                            getStartNonce(diemClient, accountInformation.getAccountAddress())
            );
        }

        for (final IDiemWritePayload iDiemWritePayload : iDiemWritePayloads) {

            if (Configuration.CREATE_ACCOUNT_PER_TRANSACTION) {
                accountInformation = accountInformationMap.get("wl-" + workloadId).get(ACCOUNT_COUNTER.get(
                        "wl-" + workloadId + "-cl-" + clientObject.getClientId()).getAndIncrement());
                startSequenceNumber = new AtomicLong(
                        Configuration.DISTRIBUTED_NONCE_HANDLING ?
                                getStartNoncePlain(diemClient, accountInformation.getAccountAddress()) :
                                getStartNonce(diemClient, accountInformation.getAccountAddress())
                );
            }

            if (iDiemWritePayload.getSenderAccountInformation() != null) {
                accountInformation = iDiemWritePayload.getSenderAccountInformation();
                LOG.info("Triggered payload with custom sender information, overwriting addresses to " + accountInformation.getAccountAddress());
                startSequenceNumber = new AtomicLong(
                        Configuration.DISTRIBUTED_NONCE_HANDLING ?
                                getStartNoncePlain(diemClient, accountInformation.getAccountAddress()) :
                                getStartNonce(diemClient, accountInformation.getAccountAddress())
                );
            }

            Listener.getObtainedEventsMap().get(clientObject.getClientId()).get(iDiemWritePayload.getEventPrefix() + iDiemWritePayload.getSignature()).setLeft(System.nanoTime());

            Map<String, MutablePair<Long, Long>> stringMutablePairMap =
                    ListenerReferenceValues.getTimeMap().computeIfAbsent(clientObject.getClientId(),
                            c -> new ConcurrentHashMap<>());
            stringMutablePairMap.computeIfAbsent(iDiemWritePayload.getEventPrefix() + iDiemWritePayload.getSignature(), m ->
                    MutablePair.of(System.currentTimeMillis(), -1L));

            //handleRequestDistribution(clientObject.getClientId());

            WriteStatisticObject writeStatisticObject = new WriteStatisticObject();
            CustomStatisticObject<String> customStatisticObject = new CustomStatisticObject<>();

            writeStatisticObject.getAssocEventList().add(iDiemWritePayload.getEventPrefix() + iDiemWritePayload.getSignature());

            writeStatisticObject.setCurrentTimeStart(System.currentTimeMillis());
            writeStatisticObject.setClientId(clientObject.getClientId());
            writeStatisticObject.setRequestNumber(++writeRequests);
            writeStatisticObject.setRequestId("clid-" + clientObject.getClientId() + "-write-" + writeRequests +
                    "-wlid" +
                    "-" + workloadId);

            write(prepareWorkloadObject, diemWrite,
                    writeStatisticObject, iDiemWritePayload, clientObject, diemClient, accountInformation,
                    startSequenceNumber, customStatisticObject);
            writeStatisticObject.setCurrentTimeEnd(System.currentTimeMillis());
            writeStatisticObject.getSpecificPayloadTypeList().add(iDiemWritePayload.getSpecificPayloadType());
            iStatistics.add(writeStatisticObject);
            iStatistics.add(customStatisticObject);

        }
    }

    @Suspendable
    private void write(final PrepareDiemWorkloadObject prepareWorkloadObject, final Write diemWrite,
                       final WriteStatisticObject writeStatisticObject, final IDiemWritePayload iDiemWritePayload,
                       final ClientObject clientObject, final DiemClient diemClient,
                       final AccountInformation accountInformation, final AtomicLong startSequenceNumber,
                       final CustomStatisticObject<String> customStatisticObject) {

        boolean hasError = true;
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

                        Listener.getObtainedEventsMap().get(clientObject.getClientId()).get(iDiemWritePayload.getEventPrefix() + iDiemWritePayload.getSignature()).setLeft(System.nanoTime());

                        Map<String, MutablePair<Long, Long>> stringMutablePairMap =
                                ListenerReferenceValues.getTimeMap().computeIfAbsent(clientObject.getClientId(),
                                        c -> new ConcurrentHashMap<>());
                        stringMutablePairMap.computeIfAbsent(iDiemWritePayload.getEventPrefix() + iDiemWritePayload.getSignature(), m ->
                                MutablePair.of(System.currentTimeMillis(), -1L));
                        timeSet = true;
                    }
                }
            }

            long nonce = 0;
            if (Configuration.DISTRIBUTED_NONCE_HANDLING) {
                try (java.sql.Connection connection = client.database.Connection.getConnection()) {

                    String query = "INSERT INTO diem_nonce AS dn (address, nonce)" +
                            "VALUES (?, ?)" +
                            "ON CONFLICT (address) DO UPDATE " +
                            "SET nonce = dn.nonce + 1 " +
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
                    preparedStatement.setString(1, accountInformation.getAccountAddress());
                    preparedStatement.setLong(2, startSequenceNumber.get());
                    ResultSet resultSet = preparedStatement.executeQuery();

                    while (resultSet.next()) {
                        LOG.info("New nonce: " + (resultSet.getInt("nonce")));
                        nonce = resultSet.getInt("nonce");
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
                nonce = NONCE_MAP.get(accountInformation.getAccountAddress()).getAndIncrement();
            }

            List<String> addressList = AccountStore.getAddressList(Configuration.ACCOUNT_FILE_LOCATION);

            if(!Configuration.PRE_PREPARE_ACCOUNTS) {
                PayloadHelper.handlePayload(iDiemWritePayload, addressList, accountInformation.getAccountAddress());
            }

            SignedTransaction signedTransaction =
                    Helper.signTransaction(new Ed25519PrivateKey(accountInformation.getPrivateKey()),
                            Helper.getRawTransaction(AccountAddressUtils.create(accountInformation.getAccountAddress()),
                                    nonce,
                                    iDiemWritePayload.getTransactionPayload(),
                                    Configuration.MAX_GAS_AMOUNT, Configuration.GAS_UNIT_PRICE,
                                    Configuration.DEFAULT_CURRENCY_CODE,
                                    Configuration.EXPIRATION_TIMESTAMP_SECS_OFFSET, Configuration.CHAIN_ID));

            writeStatisticObject.setTxId(HashUtils.transactionHash(signedTransaction));

            ImmutablePair<Boolean, String> write = diemWrite.write(diemClient, signedTransaction,
                    new Ed25519PrivateKey(accountInformation.getPrivateKey()), writeStatisticObject,
                    customStatisticObject);

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
    private long getStartNoncePlain(final DiemClient diemClient, final String address) {
        try {
            return diemClient.getAccount(address).getSequenceNumber();
        } catch (DiemException ex) {
            ExceptionHandler.logException(ex);
        }
        return 0;
    }

    @Suspendable
    private long getStartNonce(final DiemClient diemClient, final String address) {

        AtomicLong startNonce;
        synchronized (NONCE_MAP) {
            if (NONCE_MAP.get(address) == null) {
                try {
                    startNonce = new AtomicLong(diemClient.getAccount(address).getSequenceNumber());
                    NONCE_MAP.put(address, startNonce);
                    return startNonce.get();
                } catch (DiemException ex) {
                    ExceptionHandler.logException(ex);
                }
            } else {
                startNonce = NONCE_MAP.get(address);
                return startNonce.get();
            }
        }
        return 0;
    }

    @Suspendable
    private void prepareExpectedEventMap(final ClientObject clientObject,
                                         final List<IDiemWritePayload> iDiemWritePayloads) {

        for (final IDiemWritePayload iDiemWritePayload : iDiemWritePayloads) {

            String expectedEvent = iDiemWritePayload.getEventPrefix() + iDiemWritePayload.getSignature();

            Map<String, MutablePair<Long, Long>> stringMutablePairMap =
                    Listener.getObtainedEventsMap().computeIfAbsent(clientObject.getClientId(),
                            c -> new ConcurrentHashMap<>());
            stringMutablePairMap.computeIfAbsent(expectedEvent, m ->
                    MutablePair.of(System.nanoTime(), -1L));

        }
    }

    @Suspendable
    private static synchronized void unregisterListeners(final ClientObject clientObject,
                                                         final PrepareDiemWorkloadObject prepareWorkloadObject) {
        if (Configuration.UNREGISTER_LISTENERS) {
            for (final Map.Entry<String, String> listenerEntry : prepareWorkloadObject.getListener().entrySet()) {
                Listener.unregisterListener(listenerEntry.getValue());
            }

            LOG.info("Closed listeners, finished " + clientObject.getClientId());
        }
    }

    @Suspendable
    private void awaitEndOfExecution(final PrepareDiemWorkloadObject prepareWorkloadObject) {
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
    public void read(final PrepareDiemWorkloadObject prepareWorkloadObject, final ClientObject clientObject,
                     final List<IDiemReadPayload> iDiemReadPayloads, final Read read, final int workloadId) {

        RateLimiter rateLimiter = Configuration.ENABLE_RATE_LIMITER_FOR_READ_PAYLOADS ?
                RateLimiter.create(
                        GenericSelectionStrategy.selectFixed(
                                Configuration.READ_PAYLOADS_PER_SECOND, Collections.singletonList(0), false).get(0)
                ) : null;

        for (final IDiemReadPayload iDiemReadPayload : iDiemReadPayloads) {

            if (Configuration.ENABLE_RATE_LIMITER_FOR_READ_PAYLOADS) {
                rateLimiter.acquire();
            }

            ReadStatisticObject readStatisticObject = new ReadStatisticObject();
            readStatisticObject.setCurrentTimeStart(System.currentTimeMillis());
            read(prepareWorkloadObject, clientObject, iDiemReadPayload, read, readStatisticObject);
            readStatisticObject.setCurrentTimeEnd(System.currentTimeMillis());
            readStatisticObject.setRequestNumber(++readRequests);
            readStatisticObject.setClientId(clientObject.getClientId());
            readStatisticObject.setRequestId("clid-" + clientObject.getClientId() + "-read-" + readRequests + "-wlid" +
                    "-" + workloadId);
            readStatisticObject.getSpecificPayloadTypeList().add(iDiemReadPayload.getSpecificPayloadType());
            iStatistics.add(readStatisticObject);

        }

    }

    @Suspendable
    private void read(final PrepareDiemWorkloadObject prepareWorkloadObject,
                      final ClientObject clientObject,
                      final IDiemReadPayload iDiemReadPayload,
                      final Read read,
                      final ReadStatisticObject readStatisticObject) {

        boolean hasError;
        String hasMessage;
        int e = 0;
        int retries = Configuration.RESEND_TIMES_UPON_ERROR_READ;
        do {

            ImmutablePair<Boolean, String> readRes =
                    (ImmutablePair<Boolean, String>) read.read(iDiemReadPayload, readStatisticObject);

            hasError = readRes.getLeft();
            hasMessage = readRes.getRight();

            if (hasError) {
                LOG.error("Had error (read) resend " + e + " message " + hasMessage);
                e++;
            }

            if (hasError && hasMessage != null) {
                readStatisticObject.getErrorMessages().add(hasMessage);
            }

            if (Configuration.DROP_ON_TIMEOUT && readRes.getRight().contains("TIMEOUT_EX")) {
                LOG.error("Dropping read request due to exception " + readRes.getRight());
                break;
            }

        } while (hasError && e < retries);
        LOG.info("Number of resends (read): " + e);

        if (hasError) {
            readStatisticObject.setFailedRequest(true);
        }
    }

    @Suspendable
    private List<IDiemWritePayload> prepareWritePayloads(final ClientObject clientObject,
                                                         final List<PrepareDiemWorkloadObject> listOfWorkloadObjects) {
        List<IDiemWritePayload> iDiemWritePayloads;
        if (Configuration.PREPARE_WRITE_PAYLOADS) {
            String id = clientObject.getClientId() + WRITE_SUFFIX;
            List<List<IDiemWritePayload>> diemWritePayloads = listOfWorkloadObjects.get(0).getDiemWritePayloads();
            iDiemWritePayloads = GenericSelectionStrategy.selectRoundRobin(diemWritePayloads, 1, false, false,
                    id, 1, false).get(0);
        } else {

            IDiemPayloads iDiemWritePayloadPattern = null;
            try {
                iDiemWritePayloadPattern = Configuration.WRITE_PAYLOAD_PATTERN.getDeclaredConstructor().newInstance();
            } catch (InstantiationException | IllegalAccessException | InvocationTargetException | NoSuchMethodException ex) {
                ExceptionHandler.logException(ex);
            }

            iDiemWritePayloads =
                    (List<IDiemWritePayload>) Objects.requireNonNull(iDiemWritePayloadPattern).getPayloads(clientObject,
                            Configuration.NUMBER_OF_TRANSACTIONS_PER_CLIENT);
        }
        return iDiemWritePayloads;
    }

    @Suspendable
    private List<IDiemReadPayload> prepareReadPayloads(final ClientObject clientObject,
                                                       final List<PrepareDiemWorkloadObject> listOfWorkloadObjects) {
        List<IDiemReadPayload> iDiemReadPayloads;
        if (Configuration.PREPARE_READ_PAYLOADS) {
            String id = clientObject.getClientId() + READ_SUFFIX;
            List<List<IDiemReadPayload>> diemReadPayloads = listOfWorkloadObjects.get(0).getDiemReadPayloads();
            iDiemReadPayloads = GenericSelectionStrategy.selectRoundRobin(diemReadPayloads, 1, false, false,
                    id, 1, false).get(0);
        } else {

            IDiemPayloads iDiemReadPayloadPattern = null;
            try {
                iDiemReadPayloadPattern = Configuration.READ_PAYLOAD_PATTERN.getDeclaredConstructor().newInstance();
            } catch (InstantiationException | IllegalAccessException | InvocationTargetException | NoSuchMethodException ex) {
                ExceptionHandler.logException(ex);
            }

            iDiemReadPayloads =
                    (List<IDiemReadPayload>) Objects.requireNonNull(iDiemReadPayloadPattern).getPayloads(clientObject);
        }
        return iDiemReadPayloads;
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
