package diem.workloads;

import client.client.ClientObject;
import client.client.ClientRegistry;
import client.commoninterfaces.IPrepareWorkload;
import client.commoninterfaces.IRequestDistribution;
import client.configuration.GeneralConfiguration;
import client.statistics.IStatistics;
import client.supplements.ExceptionHandler;
import client.utils.GenericSelectionStrategy;
import co.paralleluniverse.fibers.Fiber;
import co.paralleluniverse.fibers.Suspendable;
import com.diem.DiemClient;
import com.diem.DiemException;
import diem.configuration.Configuration;
import diem.connection.Client;
import diem.helper.AccountInformation;
import diem.helper.AccountStore;
import diem.listener.Listener;
import diem.listener.WebsocketListener;
import diem.payload_patterns.IDiemPayloads;
import diem.payloads.IDiemReadPayload;
import diem.payloads.IDiemWritePayload;
import org.apache.log4j.Logger;

import java.lang.reflect.InvocationTargetException;
import java.util.*;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeoutException;
import java.util.concurrent.atomic.AtomicInteger;

public class PrepareDiemWorkload implements IPrepareWorkload, IRequestDistribution {

    private static final Logger LOG = Logger.getLogger(PrepareDiemWorkload.class);
    private final List<PrepareDiemWorkloadObject> paramList = new ArrayList<>();

    private final Queue<IStatistics> iStatistics = new ConcurrentLinkedQueue<>();

    private static final AtomicInteger LISTENER_COUNTER = new AtomicInteger(0);

    @SafeVarargs
    @Suspendable
    @Override
    public final <E> E prepareWorkload(final E... params) {

        ClientObject clientObject = (ClientObject) params[0];

        PrepareDiemWorkloadObject prepareDiemWorkloadObject = new PrepareDiemWorkloadObject();

        DiemClient diemClient = new Client().createClient(Configuration.CONNECTION_RETRIES,
                Configuration.WAIT_DURATION_MILLISECONDS,
                Configuration.KEEP_ALIVE_TIME,
                GenericSelectionStrategy.selectFixed(Configuration.NODE_LIST,
                        Collections.singletonList(Integer.parseInt(GeneralConfiguration.HOST_ID.split("-")[2])),
                        true).get(0),
                Configuration.CHAIN_ID
        );
        if (Configuration.PREPARE_CLIENT_CONNECTION) {
            prepareDiemWorkloadObject.setDiemClient(diemClient);
        }

        AccountStore.getAccountInformationList(Configuration.ACCOUNT_FILE_LOCATION);
        List<AccountInformation> sublist;
        if (!Configuration.CREATE_ACCOUNT_PER_TRANSACTION && !Configuration.SINGLE_ACCOUNT_FOR_WORKLOAD) {
            sublist = AccountStore.getSublist(1);

            List<AccountInformation> accountInformationList = new ArrayList<>();
            accountInformationList.add(sublist.get(0));
            prepareDiemWorkloadObject.getAccountInformationMap().put("wl-" + (1),
                    accountInformationList);
        }
        if (!Configuration.CREATE_ACCOUNT_PER_TRANSACTION && Configuration.SINGLE_ACCOUNT_FOR_WORKLOAD) {
            sublist =
                    AccountStore.getSublist(GenericSelectionStrategy.selectFixed(GeneralConfiguration.CLIENT_WORKLOADS, Collections.singletonList(0), false).get(0));

            for (int i = 0; i <
                    GenericSelectionStrategy.selectFixed(GeneralConfiguration.CLIENT_WORKLOADS,
                            Collections.singletonList(0), false).get(0);
                 i++) {
                List<AccountInformation> accountInformationList = new ArrayList<>();
                accountInformationList.add(sublist.get(i));
                prepareDiemWorkloadObject.getAccountInformationMap().put("wl-" + (i + 1),
                        accountInformationList);
            }

        }

        if (Configuration.CREATE_ACCOUNT_PER_TRANSACTION) {
            sublist =
                    AccountStore.getSublist(GenericSelectionStrategy.selectFixed(GeneralConfiguration.CLIENT_WORKLOADS, Collections.singletonList(0), false).get(0) * Configuration.NUMBER_OF_TRANSACTIONS_PER_CLIENT);

            int p = 0;
            for (int i = 0; i <
                    GenericSelectionStrategy.selectFixed(GeneralConfiguration.CLIENT_WORKLOADS,
                            Collections.singletonList(0), false).get(0);
                 i++) {
                List<AccountInformation> accountInformationList = new ArrayList<>();
                for (int j = 0; j <
                        Configuration.NUMBER_OF_TRANSACTIONS_PER_CLIENT;
                     j++) {
                    accountInformationList.add(sublist.get(p));
                    p++;
                }
                prepareDiemWorkloadObject.getAccountInformationMap().put("wl-" + (i + 1),
                        accountInformationList);
            }
        }

        long startVersion = 0;
        if (Configuration.USE_FIXED_START_VERSION) {
            startVersion = Configuration.START_VERSION;
        } else {
            try {
                startVersion = diemClient.getMetadata().getVersion();
            } catch (DiemException ex) {
                ExceptionHandler.logException(ex);
            }
        }

        String websocketSubscriptionServer =
                GenericSelectionStrategy.selectFixed(Configuration.NODES_TO_SUBSCRIBE_TO_WS,
                        Collections.singletonList(0), false).get(0);

        prepareListener(clientObject, startVersion, websocketSubscriptionServer, prepareDiemWorkloadObject);

        prepareWritePayloads(clientObject, prepareDiemWorkloadObject);
        prepareReadPayloads(clientObject, prepareDiemWorkloadObject);

        paramList.add(prepareDiemWorkloadObject);
        return (E) prepareDiemWorkloadObject;
    }

    @Suspendable
    private void prepareWritePayloads(final ClientObject clientObject,
                                      final PrepareDiemWorkloadObject prepareDiemWorkloadObject) {
        if (Configuration.PREPARE_WRITE_PAYLOADS) {
            List<List<IDiemWritePayload>> completeWritePayloadList = new ArrayList<>();
            for (int i = 0; i < GenericSelectionStrategy.selectFixed(GeneralConfiguration.CLIENT_WORKLOADS,
                    Collections.singletonList(0), false).get(0); i++) {

                IDiemPayloads iDiemWritePayloadPattern = null;
                try {
                    iDiemWritePayloadPattern =
                            Configuration.WRITE_PAYLOAD_PATTERN.getDeclaredConstructor().newInstance();
                } catch (InstantiationException | IllegalAccessException | InvocationTargetException | NoSuchMethodException ex) {
                    ExceptionHandler.logException(ex);
                }

                List<IDiemWritePayload> iDiemWritePayloads =
                        (List<IDiemWritePayload>) Objects.requireNonNull(iDiemWritePayloadPattern).getPayloads(clientObject,
                                Configuration.NUMBER_OF_TRANSACTIONS_PER_CLIENT);
                completeWritePayloadList.add(iDiemWritePayloads);
            }
            prepareDiemWorkloadObject.setDiemWritePayloads(completeWritePayloadList);
        }
    }

    @Suspendable
    private void prepareReadPayloads(final ClientObject clientObject,
                                     final PrepareDiemWorkloadObject prepareDiemWorkloadObject) {
        if (Configuration.PREPARE_READ_PAYLOADS) {
            List<List<IDiemReadPayload>> completeReadPayloadList = new ArrayList<>();
            for (int i = 0; i < GenericSelectionStrategy.selectFixed(GeneralConfiguration.CLIENT_WORKLOADS,
                    Collections.singletonList(0), false).get(0); i++) {

                IDiemPayloads iDiemReadPayloadPattern = null;
                try {
                    iDiemReadPayloadPattern =
                            Configuration.READ_PAYLOAD_PATTERN.getDeclaredConstructor().newInstance();
                } catch (InstantiationException | IllegalAccessException | InvocationTargetException | NoSuchMethodException ex) {
                    ExceptionHandler.logException(ex);
                }

                List<IDiemReadPayload> iDiemReadPayloads =
                        (List<IDiemReadPayload>) Objects.requireNonNull(iDiemReadPayloadPattern).getPayloads(clientObject);
                completeReadPayloadList.add(iDiemReadPayloads);
            }
            prepareDiemWorkloadObject.setDiemReadPayloads(completeReadPayloadList);
        }
    }

    @Suspendable
    private void prepareListener(final ClientObject clientObject, final long startVersion,
                                 final String urlToSubscribeTo,
                                 final PrepareDiemWorkloadObject prepareDiemWorkloadObject) {
        if (Configuration.ENABLE_LISTENER) {
            if (LISTENER_COUNTER.getAndIncrement() < Configuration.NUMBER_OF_LISTENERS) {
                LOG.info("Registering listener for: " + clientObject.getClientId());

                Listener listener =
                        new Listener(GeneralConfiguration.CLIENT_COUNT * GenericSelectionStrategy.selectFixed(GeneralConfiguration.CLIENT_WORKLOADS,
                                Collections.singletonList(0), false).get(0) * Configuration.NUMBER_OF_TRANSACTIONS_PER_CLIENT,
                                GeneralConfiguration.CLIENT_COUNT * GenericSelectionStrategy.selectFixed(GeneralConfiguration.CLIENT_WORKLOADS, Collections.singletonList(0), false).get(0) * Configuration.NUMBER_OF_TRANSACTIONS_PER_CLIENT
                                , Configuration.LISTENER_THRESHOLD, Configuration.LISTENER_TOTAL_THRESHOLD,
                                iStatistics);
                if (Configuration.LISTENER_AS_THREAD) {
                    Thread thread = new Thread(() -> {
                        prepareListenerLogic(clientObject, prepareDiemWorkloadObject, startVersion, urlToSubscribeTo,
                                listener);
                    });
                    thread.setName(clientObject.getClientId() + "-listener-thread");
                    thread.setUncaughtExceptionHandler((t, ex) -> ExceptionHandler.logException(ex));
                    thread.setPriority(GeneralConfiguration.LISTENER_PRIORITY);
                    thread.start();
                } else {
                    Fiber<Void> fiber = new Fiber<>(() -> {
                        prepareListenerLogic(clientObject, prepareDiemWorkloadObject, startVersion, urlToSubscribeTo,
                                listener);
                    });
                    fiber.setName(clientObject.getClientId() + "-listener-fiber");
                    fiber.setUncaughtExceptionHandler((t, ex) -> ExceptionHandler.logException(ex));
                    fiber.setPriority(GeneralConfiguration.LISTENER_PRIORITY);
                    fiber.start();
                }

                try {
                    listener.getIsSubscribed().get(Configuration.TIMEOUT_LISTENER,
                            Configuration.TIMEOUT_LISTENER_TIME_UNIT);
                } catch (InterruptedException | ExecutionException | TimeoutException ex) {
                    ExceptionHandler.logException(ex);
                }
            }
        }
    }

    @Suspendable
    private void prepareListenerLogic(final ClientObject clientObject,
                                      final PrepareDiemWorkloadObject prepareDiemWorkloadObject,
                                      final long startVersion, final String urlToSubscribeTo, final Listener listener) {

        WebsocketListener websocketListener = new WebsocketListener();
        websocketListener.createWebsocketListener(urlToSubscribeTo, clientObject.getClientId(),
                startVersion, ClientRegistry.getClientObjects(), listener);
        try {
            websocketListener.getIsSubscribed().get(Configuration.TIMEOUT_LISTENER,
                    Configuration.TIMEOUT_LISTENER_TIME_UNIT);
        } catch (InterruptedException | ExecutionException | TimeoutException ex) {
            ExceptionHandler.logException(ex);
        }
        listener.getIsSubscribed().complete(true);

        prepareDiemWorkloadObject.getListener().put(urlToSubscribeTo, clientObject.getClientId());

        prepareDiemWorkloadObject.getIListenerDisconnectionLogicList().addAll(Arrays.asList(listener));
    }

    @Suspendable
    public <E> List<E> getParams() {
        return (List<E>) paramList;
    }

    @SafeVarargs
    @Suspendable
    @Override
    public final <E> E endPrepareWorkload(final E... params) {
        LOG.info(((ClientObject) params[0]).getClientId() + " client preparation ended");
        return null;
    }

    @SafeVarargs
    @Override
    @Suspendable
    public final synchronized <E> Queue<IStatistics> getStatistics(final E... params) {
        return iStatistics;
    }

    @SafeVarargs
    @Override
    @Suspendable
    public final <E> void handleRequestDistribution(final E... params) {
    }
}
