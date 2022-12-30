package diem.configuration;

import client.configuration.GeneralConfiguration;
import com.diem.types.ChainId;
import diem.payload_patterns.DiemSingleReadPayload;
import diem.payload_patterns.IDiemPayloads;
import diem.payload_patterns.keyvalue.DiemUniformKeyValueSetPayload;
import diem.payloads.GeneralReadPayload;
import diem.payloads.GeneralTransactionPayload;
import diem.payloads.IDiemReadPayload;
import diem.payloads.IDiemWritePayload;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.TimeUnit;

public final class ConfigurationAsVariables {

    public static final int NUMBER_OF_TRANSACTIONS_PER_CLIENT = 1;
    public static final int RESEND_TIMES_UPON_ERROR_WRITE = 0;
    public static final int RESEND_TIMES_UPON_ERROR_READ = 3;
    public static final boolean PREPARE_WRITE_PAYLOADS = false;

    public static final boolean SEND_WRITE_ASYNC = false;
    public static final boolean SEND_WRITE_SYNC = true;

    public static final boolean LISTENER_AS_THREAD = false;

    public static final int DEFAULT_PAGE_NUMBER = 1;
    public static final int DEFAULT_PAGE_SIZE = 10000;

    public static final Class<? extends IDiemWritePayload> WRITE_PAYLOAD = GeneralTransactionPayload.class;
    public static final Class<? extends IDiemReadPayload> READ_PAYLOAD = GeneralReadPayload.class;

    public static final boolean PREPARE_CLIENT_CONNECTION = true;
    public static final int CONNECTION_RETRIES = 5;
    public static final long WAIT_DURATION_MILLISECONDS = 200;
    public static final Long KEEP_ALIVE_TIME = 30000L;
    public static final ChainId CHAIN_ID = new ChainId((byte) 4);
    public static final String DEFAULT_CURRENCY_CODE = "XUS";
    public static final long DEFAULT_SLIDING_NONCE = 0;
    public static final boolean ADD_ALL_CURRENCIES = true;
    public static final boolean FILL_ACCOUNTS = true;
    public static final boolean USE_FAUCET = false;
    public static final String FAUCET_SERVER_LIST = "http://192.168.2.112:2994/mint";
    public static final long DEFAULT_MINT_AMOUNT = 100000000000L;
    public static final int CONTENT_LENGTH = 1500;
    public static final boolean CREATE_ACCOUNTS = true;
    public static final boolean USE_FIXED_START_VERSION = false;
    public static final long START_VERSION = -1;
    public static final boolean DISTRIBUTED_NONCE_HANDLING = false;
    public static final boolean DISTRIBUTED_NONCE_HANDLING_PREPARE = true;
    public static final String MAIN_ADDRESS = "0000000000000000000000000b1e55ed";
    public static final String DD_ADDRESS = "000000000000000000000000000000DD";
    public static final boolean UNREGISTER_LISTENERS = true;
    public static final boolean CREATE_ACCOUNT_PER_TRANSACTION = true;
    public static final boolean CHECK_TRANSACTION_VALIDITY = true;
    public static final String MINT_KEY_LOCATION = "/home/mint.key";
    public static final String SERVERS_TO_READ_FROM = "http://192.168.2.111:26000/transactions/";

    /*
    https://github.com/diem/diem/blob/ce59ea18a0a9e749560c9a4e88bde62df54537a4/language/move-lang/functional-tests
    /tests/diem/on_chain_config/vm_config.move
    https://github.com/diem/diem/blob/a5d1c18c7cd0587c54a237492e81cc77632089c9/diem-move/diem-framework/DPN/releases
    /artifacts/current/build/DiemCoreFramework/docs/DiemVMConfig.md
    https://github.com/diem/diem/blob/0cdde0d258a3706d7d84d05225899df8518f319a/diem-move/diem-framework/DPN/releases
    /artifacts/release-1.2.0-rc0/docs/modules/SystemAdministrationScripts.md
    https://github.com/diem/diem/blob/46333a0c40c6e9acbcbcb9fe44e6c7030f86f387/types/src/on_chain_config
    /consensus_config.rs
     */
    public static final long MAX_GAS_AMOUNT = 4000000;
    public static final long GAS_UNIT_PRICE = 0;
    public static final long EXPIRATION_TIMESTAMP_SECS_OFFSET = 300;
    public static final long EXPIRATION_TIMESTAMP_SECS_OFFSET_ACCOUNT_CREATION = 1500;
    public static final String ACCOUNT_FILE_LOCATION = "/home/diem_accounts.txt";
    public static final long DATABASE_SLEEP_TIME = 500;
    public static final long RECONNECTION_SLEEP_TIME = 500;
    public static final boolean SINGLE_ACCOUNT_FOR_WORKLOAD = true;

    public static final long TIMEOUT_TRANSACTION = 3;
    public static final TimeUnit TIMEOUT_UNIT_TRANSACTION = TimeUnit.MINUTES;
    public static final int TIMEOUT_TRANSACTION_SEND = 120;
    public static final boolean DROP_ON_TIMEOUT = true;
    public static final boolean ENABLE_BLOCK_STATISTICS = false;
    public static final int PREPARE_THREAD_NUMBER = 8;
    public static final int MAX_RETRIES_FAUCET = 10;
    public static final long WAIT_DURATION_MILLIS_FAUCET = 500;
    public static final int DEFAULT_TX_TIMEOUT_FAUCET = 10 * 1000;
    public static final boolean CUSTOM_STATISTIC_GAS_USED_TX = true;

    public static final long RUNTIME = 30000L;
    public static final int NUMBER_OF_PREDEFINED_ACCOUNTS = 2;
    public static final  boolean PRE_PREPARE_ACCOUNTS = true;

    public static final boolean RECEIVE_READ_REQUEST = true;

    public static final int MAX_CONNECTION_RETRIES = 100;

    public static final double LISTENER_THRESHOLD = 1.0;

    public static final Class<? extends IDiemPayloads> WRITE_PAYLOAD_PATTERN = DiemUniformKeyValueSetPayload.class;
    public static final Class<? extends IDiemPayloads> READ_PAYLOAD_PATTERN = DiemSingleReadPayload.class;

    public static final double LISTENER_TOTAL_THRESHOLD = 1.0;
    public static final int NUMBER_OF_LISTENERS = GeneralConfiguration.CLIENT_COUNT;
    public static final boolean ENABLE_LISTENER = true;
    public static final long TIMEOUT_LISTENER = 10;
    public static final TimeUnit TIMEOUT_LISTENER_TIME_UNIT = TimeUnit.MINUTES;

    public static final boolean ENABLE_RATE_LIMITER_FOR_WRITE_PAYLOADS = false;
    public static final List<Double> WRITE_PAYLOADS_PER_SECOND = new ArrayList<>(Arrays.asList(1.0 / 60));
    public static final boolean PREPARE_READ_PAYLOADS = false;
    public static final boolean ENABLE_RATE_LIMITER_FOR_READ_PAYLOADS = false;
    public static final List<Double> READ_PAYLOADS_PER_SECOND = new ArrayList<>(Arrays.asList(1.0));
    public static final boolean RETURN_ON_EVENT_DUPLICATE = true;
    public static final boolean SEND_WRITE_REQUESTS = true;
    public static final boolean SEND_READ_REQUESTS = false;
    public static final List<String> EVENT_EXISTS_SUFFIX_LIST = new ArrayList<>(Arrays.asList("/exist"));
    public static final boolean HANDLE_EVENT_SYNCHRONIZED = true;

    static {
        boolean potentialInconsistent = false;
        System.out.println("Checking for potential inconsistencies of the configuration...");
        System.out.println("Config potentially consistent: " + !potentialInconsistent);
    }

    private ConfigurationAsVariables() {
    }

}
