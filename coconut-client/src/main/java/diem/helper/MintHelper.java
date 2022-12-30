package diem.helper;

import client.configuration.GeneralConfiguration;
import client.supplements.ExceptionHandler;
import client.utils.GenericSelectionStrategy;
import co.paralleluniverse.fibers.Suspendable;
import com.diem.AuthKey;
import com.diem.DiemClient;
import com.diem.DiemException;
import com.diem.PrivateKey;
import com.diem.jsonrpc.JsonRpc;
import com.diem.types.SignedTransaction;
import com.diem.utils.AccountAddressUtils;
import cy.agorise.graphenej.Util;
import diem.configuration.Configuration;
import diem.connection.Client;
import diem.connection.Testnet;
import diem.payload_patterns.PreparedPayloadScripts;
import net.i2p.crypto.eddsa.Utils;
import org.apache.commons.lang3.RandomStringUtils;
import org.apache.log4j.Logger;

import java.util.*;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicLong;

public class MintHelper {
    private MintHelper() {
    }

    private static final Logger LOG = Logger.getLogger(MintHelper.class);

    private static final Map<String, Long> NONCE_MAP = new ConcurrentHashMap<>();
    private static final AtomicLong MAIN_NONCE = new AtomicLong(0);
    private static final AtomicLong DD_NONCE = new AtomicLong(0);
    private static final AtomicBoolean MAIN_NONCE_SET = new AtomicBoolean(false);
    private static final AtomicBoolean DD_NONCE_SET = new AtomicBoolean(false);

    private static final Map<String, List<AccountInformation>> ACCOUNT_INFORMATION_MAP =
            Collections.synchronizedMap(new LinkedHashMap<>());

    private static final int RANGE = GeneralConfiguration.CLIENT_COUNT * (Configuration.CREATE_ACCOUNT_PER_TRANSACTION || Configuration.SINGLE_ACCOUNT_FOR_WORKLOAD ?
                    GenericSelectionStrategy.selectFixed(GeneralConfiguration.CLIENT_WORKLOADS,
                            Collections.singletonList(0), false).get(0) : 1) * (Configuration.CREATE_ACCOUNT_PER_TRANSACTION ?
                    Configuration.NUMBER_OF_TRANSACTIONS_PER_CLIENT : 1);
    private static final AtomicLong CURRENT_MAIN = new AtomicLong(0);
    private static final AtomicLong CURRENT_DD = new AtomicLong(0);
    private static final AtomicInteger RANGE_COUNTER_MAIN = new AtomicInteger(0);
    private static final AtomicInteger RANGE_COUNTER_DD = new AtomicInteger(0);

    private static final List<SignedTransaction> SIGNED_TRANSACTION_LIST = new ArrayList<>();
    private static final List<SignedTransaction> SIGNED_TRANSACTION_LIST_MINT = new ArrayList<>();

    @Suspendable
    public static void mintAccounts() {
        DiemClient diemClient = new Client().createClient(Configuration.CONNECTION_RETRIES,
                Configuration.WAIT_DURATION_MILLISECONDS,
                Configuration.KEEP_ALIVE_TIME,
                GenericSelectionStrategy.selectFixed(Configuration.NODE_LIST,
                        Collections.singletonList(Integer.parseInt(GeneralConfiguration.HOST_ID.split("-")[2])),
                        true).get(0),
                Configuration.CHAIN_ID
        );

        try {
            if (Configuration.CREATE_ACCOUNTS) {

                if (Configuration.PRE_PREPARE_ACCOUNTS) {
                    Helper.deleteAccountFile(Configuration.ACCOUNT_FILE_LOCATION);
                    Helper.preparePredefinedAccountsFile(Configuration.ACCOUNT_FILE_LOCATION);
                    LOG.info("Use pre-prepared accounts");
                    return;
                }

                ExecutorService executorServiceRegister =
                        Executors.newFixedThreadPool(Configuration.PREPARE_THREAD_NUMBER);
                List<CompletableFuture<Void>> futuresRegister = new ArrayList<>();

                Helper.deleteAccountFile(Configuration.ACCOUNT_FILE_LOCATION);

                JsonRpc.Account mainAccount = diemClient.getAccount(AccountAddressUtils.create(
                        Configuration.MAIN_ADDRESS));
                JsonRpc.Account designatedDealerAccount = diemClient.getAccount(AccountAddressUtils.create(
                        Configuration.DD_ADDRESS));
                if (!Configuration.DISTRIBUTED_NONCE_HANDLING_PREPARE) {
                    handleNonceValues(diemClient);
                }

                    for (int k = 0; k < GeneralConfiguration.CLIENT_COUNT; k++) {
                        for (int i = 0; i <
                                (Configuration.CREATE_ACCOUNT_PER_TRANSACTION || Configuration.SINGLE_ACCOUNT_FOR_WORKLOAD ?
                                        GenericSelectionStrategy.selectFixed(GeneralConfiguration.CLIENT_WORKLOADS,
                                                Collections.singletonList(0), false).get(0) : 1);
                             i++) {

                            List<AccountInformation> accountInformationList = Collections.synchronizedList(new ArrayList<>());

                            for (int j = 0; j <
                                    (Configuration.CREATE_ACCOUNT_PER_TRANSACTION ?
                                            Configuration.NUMBER_OF_TRANSACTIONS_PER_CLIENT : 1);
                                 j++) {

                                futuresRegister.add(CompletableFuture.runAsync(() -> {

                                try {

                                    PrivateKey privateKey = Helper.getNewPrivateKey();
                                    byte[] privateKeyData = Helper.getPrivateKeyData(privateKey);
                                    AuthKey authKey = AuthKey.ed25519(privateKey.publicKey());

                                    AccountInformation accountInformation =
                                            new AccountInformation(Util.bytesToHex(privateKeyData),
                                                    Utils.bytesToHex(privateKey.publicKey()),
                                                    AccountAddressUtils.hex(authKey.accountAddress()), authKey.hex());

                                    if (!Configuration.USE_FAUCET) {
                                        SignedTransaction signedTransactionCreateAccount =
                                                Helper.signTransaction(Helper.getMintKey(Configuration.MINT_KEY_LOCATION),
                                                        Helper.getRawTransaction(AccountAddressUtils.create(mainAccount.getAddress()),
                                                                (Configuration.DISTRIBUTED_NONCE_HANDLING_PREPARE ?
                                                                        Helper.updateNonceRange(Configuration.MAIN_ADDRESS,
                                                                                getStartNoncePlain(diemClient,
                                                                                        Configuration.MAIN_ADDRESS),
                                                                                RANGE, RANGE_COUNTER_MAIN,
                                                                                CURRENT_MAIN) :
                                                                        MAIN_NONCE.getAndIncrement()),
                                                                PreparedPayloadScripts.getCreateParentVaspAccountPayload(
                                                                        Configuration.DEFAULT_CURRENCY_CODE,
                                                                        Configuration.DEFAULT_SLIDING_NONCE,
                                                                        AccountAddressUtils.create(accountInformation.getAccountAddress()),
                                                                        AuthKey.ed25519(Util.hexToBytes(accountInformation.getPublicKey())).prefix(),
                                                                        RandomStringUtils.random(12, true, true),
                                                                        Configuration.ADD_ALL_CURRENCIES
                                                                ),
                                                                Configuration.MAX_GAS_AMOUNT,
                                                                Configuration.GAS_UNIT_PRICE,
                                                                Configuration.DEFAULT_CURRENCY_CODE,
                                                                Configuration.EXPIRATION_TIMESTAMP_SECS_OFFSET_ACCOUNT_CREATION,
                                                                Configuration.CHAIN_ID));
                                        diemClient.submit(signedTransactionCreateAccount);
                                        //diemClient.waitForTransaction(signedTransactionCreateAccount,
                                        //        Configuration.TIMEOUT_TRANSACTION_ACCOUNT_CREATION);
                                        SIGNED_TRANSACTION_LIST.add(signedTransactionCreateAccount);
                                    }

                                    accountInformationList.add(accountInformation);
                                    Helper.writeAccountInformationToFile(Configuration.ACCOUNT_FILE_LOCATION,
                                            accountInformation.getPrivateKey(),
                                            accountInformation.getPublicKey(), accountInformation.getAccountAddress(),
                                            accountInformation.getAuthKey());
                                } catch (DiemException ex) {
                                    ExceptionHandler.logException(ex);
                                }

                            }, executorServiceRegister));

                                ACCOUNT_INFORMATION_MAP.put("wl-" + (k + 1) + "-" + (i + 1),
                                    accountInformationList);

                        }
                    }
                }

                CompletableFuture<Void> completableFutureRegister =
                        CompletableFuture.allOf(futuresRegister.toArray(new CompletableFuture[0]));
                try {
                    completableFutureRegister.get(Configuration.TIMEOUT_TRANSACTION,
                            Configuration.TIMEOUT_UNIT_TRANSACTION);
                } catch (InterruptedException | ExecutionException | TimeoutException ex) {
                    ExceptionHandler.logException(ex);
                }

                executorServiceRegister.shutdown();

                if (!Configuration.USE_FAUCET) {
                    SIGNED_TRANSACTION_LIST.parallelStream().forEach(signedTransaction ->
                            {
                                try {
                                    diemClient.waitForTransaction(signedTransaction,
                                            Configuration.TIMEOUT_TRANSACTION_ACCOUNT_CREATION);
                                    LOG.trace("Waited for tx");
                                } catch (DiemException ex) {
                                    ExceptionHandler.logException(ex);
                                }
                            }
                    );
                }

                if (Configuration.FILL_ACCOUNTS) {

                    ExecutorService executorServiceFill =
                            Executors.newFixedThreadPool(Configuration.PREPARE_THREAD_NUMBER);
                    List<CompletableFuture<Void>> futuresFill = new ArrayList<>();

                    for (int k = 0; k < GeneralConfiguration.CLIENT_COUNT; k++) {
                        for (int i = 0; i <
                                (Configuration.CREATE_ACCOUNT_PER_TRANSACTION || Configuration.SINGLE_ACCOUNT_FOR_WORKLOAD ?
                                        GenericSelectionStrategy.selectFixed(GeneralConfiguration.CLIENT_WORKLOADS,
                                                Collections.singletonList(0), false).get(0) : 1);
                             i++) {

                            List<AccountInformation> accountInformationList =
                                    ACCOUNT_INFORMATION_MAP.get("wl-" + (k + 1) + "-" + (i + 1));

                            for (int j = 0; j <
                                    (Configuration.CREATE_ACCOUNT_PER_TRANSACTION ?
                                            Configuration.NUMBER_OF_TRANSACTIONS_PER_CLIENT : 1);
                                 j++) {

                                int finalJ = j;
                                futuresFill.add(CompletableFuture.runAsync(() -> {

                                    if (Configuration.USE_FAUCET) {
                                        Testnet.mintCoins(diemClient, Configuration.DEFAULT_MINT_AMOUNT,
                                                accountInformationList.get(finalJ).getAuthKey(),
                                                Configuration.DEFAULT_CURRENCY_CODE);
                                    } else {
                                        try {
                                            SignedTransaction signedTransactionMint =
                                                    Helper.signTransaction(Helper.getMintKey(Configuration.MINT_KEY_LOCATION),
                                                            Helper.getRawTransaction(AccountAddressUtils.create(designatedDealerAccount.getAddress()),
                                                                    (Configuration.DISTRIBUTED_NONCE_HANDLING_PREPARE ?
                                                                            Helper.updateNonceRange(Configuration.DD_ADDRESS,
                                                                                    getStartNoncePlain(diemClient,
                                                                                            Configuration.DD_ADDRESS),
                                                                                    RANGE, RANGE_COUNTER_DD,
                                                                                    CURRENT_DD) :
                                                                            DD_NONCE.getAndIncrement()),
                                                                    PreparedPayloadScripts.getPeerToPeerWithMetadataPayload(
                                                                            Configuration.DEFAULT_CURRENCY_CODE,
                                                                            AccountAddressUtils.create(accountInformationList.get(finalJ).getAccountAddress()),
                                                                            Configuration.DEFAULT_MINT_AMOUNT,
                                                                            new byte[0],
                                                                            new byte[0]
                                                                    ), Configuration.MAX_GAS_AMOUNT,
                                                                    Configuration.GAS_UNIT_PRICE,
                                                                    Configuration.DEFAULT_CURRENCY_CODE,
                                                                    Configuration.EXPIRATION_TIMESTAMP_SECS_OFFSET_ACCOUNT_CREATION,
                                                                    Configuration.CHAIN_ID));
                                            diemClient.submit(signedTransactionMint);
                                            //diemClient.waitForTransaction(signedTransactionMint,
                                            //        Configuration.TIMEOUT_TRANSACTION_ACCOUNT_CREATION);
                                            SIGNED_TRANSACTION_LIST_MINT.add(signedTransactionMint);

                                        } catch (DiemException ex) {
                                            ExceptionHandler.logException(ex);
                                        }
                                    }

                                }, executorServiceFill));
                            }

                        }
                    }

                    if (Configuration.USE_FAUCET) {
                        CompletableFuture<Void> completableFutureMint =
                                CompletableFuture.allOf(futuresFill.toArray(new CompletableFuture[0]));
                        try {
                            completableFutureMint.get(Configuration.TIMEOUT_TRANSACTION,
                                    Configuration.TIMEOUT_UNIT_TRANSACTION);
                        } catch (InterruptedException | ExecutionException | TimeoutException ex) {
                            ExceptionHandler.logException(ex);
                        }
                        executorServiceFill.shutdown();
                    }

                    if (!Configuration.USE_FAUCET) {
                        SIGNED_TRANSACTION_LIST_MINT.parallelStream().forEach(signedTransaction ->
                                {
                                    try {
                                        diemClient.waitForTransaction(signedTransaction,
                                                Configuration.TIMEOUT_TRANSACTION_ACCOUNT_CREATION);
                                        LOG.trace("Waited for tx (mint)");
                                    } catch (DiemException ex) {
                                        ExceptionHandler.logException(ex);
                                    }
                                }
                        );
                        executorServiceFill.shutdown();
                    }

                }

            }
        } catch (DiemException ex) {
            ExceptionHandler.logException(ex);
        }

    }

    @Suspendable
    private static void handleNonceValues(final DiemClient diemClient) {
        if (!MAIN_NONCE_SET.get()) {
            MAIN_NONCE.addAndGet(getStartNonce(diemClient, Configuration.MAIN_ADDRESS));
            MAIN_NONCE_SET.set(true);
        }
        if (!DD_NONCE_SET.get()) {
            DD_NONCE.addAndGet(getStartNonce(diemClient, Configuration.DD_ADDRESS));
            DD_NONCE_SET.set(true);
        }
    }

    @Suspendable
    private static long getStartNoncePlain(final DiemClient diemClient, final String address) {
        try {
            return diemClient.getAccount(address).getSequenceNumber();
        } catch (DiemException ex) {
            ExceptionHandler.logException(ex);
        }
        return 0;
    }

    @Suspendable
    private static long getStartNonce(final DiemClient diemClient, final String address) {
        return NONCE_MAP.computeIfAbsent(address, s ->
        {
            try {
                return diemClient.getAccount(address).getSequenceNumber();
            } catch (DiemException ex) {
                ExceptionHandler.logException(ex);
            }
            return 0L;
        });
    }

}
