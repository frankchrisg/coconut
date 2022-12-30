package diem.configuration;

import client.configuration.GeneralConfiguration;
import client.supplements.ExceptionHandler;
import com.diem.types.ChainId;
import diem.payload_patterns.IDiemPayloads;
import diem.payloads.IDiemReadPayload;
import diem.payloads.IDiemWritePayload;
import org.apache.commons.configuration2.PropertiesConfiguration;
import org.apache.commons.configuration2.builder.FileBasedConfigurationBuilder;
import org.apache.commons.configuration2.builder.fluent.Parameters;
import org.apache.commons.configuration2.convert.DefaultListDelimiterHandler;
import org.apache.commons.configuration2.ex.ConfigurationException;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.concurrent.TimeUnit;

public final class Configuration {

    private static final Path CURRENT_RELATIVE_PATH = Paths.get("");
    private static final String CURRENT_ABSOLUTE_PATH = CURRENT_RELATIVE_PATH.toAbsolutePath().toString();
    public static final String FILE_NAME = "diemConfiguration.properties";
    public static final String FILE_PATH = "/configs/";

    static {
        try {
            PROPERTIES_CONFIGURATION =
                    new FileBasedConfigurationBuilder<>(PropertiesConfiguration.class)
                            .configure(new Parameters()
                                    .properties()
                                    .setBasePath(CURRENT_ABSOLUTE_PATH + FILE_PATH)
                                    .setFileName(FILE_NAME)
                                    .setListDelimiterHandler(new DefaultListDelimiterHandler(',')))
                            .getConfiguration();
        } catch (ConfigurationException ex) {
            ExceptionHandler.logException(ex);
        }

    }

    private static PropertiesConfiguration PROPERTIES_CONFIGURATION;

    public static Class<? extends IDiemWritePayload> WRITE_PAYLOAD;
    public static Class<? extends IDiemReadPayload> READ_PAYLOAD;
    public static final int NUMBER_OF_TRANSACTIONS_PER_CLIENT = PROPERTIES_CONFIGURATION.getInt(
            "NUMBER_OF_TRANSACTIONS_PER_CLIENT");
    public static final int RESEND_TIMES_UPON_ERROR_WRITE = PROPERTIES_CONFIGURATION.getInt(
            "RESEND_TIMES_UPON_ERROR_WRITE");
    public static final int RESEND_TIMES_UPON_ERROR_READ = PROPERTIES_CONFIGURATION.getInt(
            "RESEND_TIMES_UPON_ERROR_READ");

    public static final boolean PREPARE_CLIENT_CONNECTION = PROPERTIES_CONFIGURATION.getBoolean(
            "PREPARE_CLIENT_CONNECTION");
    public static final int CONNECTION_RETRIES = PROPERTIES_CONFIGURATION.getInt("CONNECTION_RETRIES");
    public static final long WAIT_DURATION_MILLISECONDS = PROPERTIES_CONFIGURATION.getLong(
            "WAIT_DURATION_MILLISECONDS");
    public static final Long KEEP_ALIVE_TIME = PROPERTIES_CONFIGURATION.getLong("KEEP_ALIVE_TIME");
    public static final ChainId CHAIN_ID = new ChainId(PROPERTIES_CONFIGURATION.getByte("CHAIN_ID"));
    public static final String DEFAULT_CURRENCY_CODE = PROPERTIES_CONFIGURATION.getString("DEFAULT_CURRENCY_CODE");
    public static final long DEFAULT_SLIDING_NONCE = PROPERTIES_CONFIGURATION.getLong("DEFAULT_SLIDING_NONCE");
    public static final boolean ADD_ALL_CURRENCIES = PROPERTIES_CONFIGURATION.getBoolean("ADD_ALL_CURRENCIES");
    public static final boolean FILL_ACCOUNTS = PROPERTIES_CONFIGURATION.getBoolean("FILL_ACCOUNTS");
    public static final boolean USE_FAUCET = PROPERTIES_CONFIGURATION.getBoolean("USE_FAUCET");
    public static final String FAUCET_SERVER_LIST = PROPERTIES_CONFIGURATION.getString("FAUCET_SERVER_LIST");
    public static final long DEFAULT_MINT_AMOUNT = PROPERTIES_CONFIGURATION.getLong("DEFAULT_MINT_AMOUNT");
    public static final int CONTENT_LENGTH = PROPERTIES_CONFIGURATION.getInt("CONTENT_LENGTH");
    public static final boolean CREATE_ACCOUNTS = PROPERTIES_CONFIGURATION.getBoolean("CREATE_ACCOUNTS");
    public static final boolean USE_FIXED_START_VERSION = PROPERTIES_CONFIGURATION.getBoolean(
            "USE_FIXED_START_VERSION");
    public static final long START_VERSION = PROPERTIES_CONFIGURATION.getLong("START_VERSION");
    public static final boolean DISTRIBUTED_NONCE_HANDLING = PROPERTIES_CONFIGURATION.getBoolean(
            "DISTRIBUTED_NONCE_HANDLING");
    public static final boolean DISTRIBUTED_NONCE_HANDLING_PREPARE = PROPERTIES_CONFIGURATION.getBoolean(
            "DISTRIBUTED_NONCE_HANDLING_PREPARE");
    public static final String MAIN_ADDRESS = PROPERTIES_CONFIGURATION.getString("MAIN_ADDRESS");
    public static final String DD_ADDRESS = PROPERTIES_CONFIGURATION.getString("DD_ADDRESS");
    public static final boolean UNREGISTER_LISTENERS = PROPERTIES_CONFIGURATION.getBoolean("UNREGISTER_LISTENERS");
    public static final boolean CREATE_ACCOUNT_PER_TRANSACTION = PROPERTIES_CONFIGURATION.getBoolean(
            "CREATE_ACCOUNT_PER_TRANSACTION");
    public static final boolean CHECK_TRANSACTION_VALIDITY = PROPERTIES_CONFIGURATION.getBoolean(
            "CHECK_TRANSACTION_VALIDITY");
    public static final String MINT_KEY_LOCATION = PROPERTIES_CONFIGURATION.getString("MINT_KEY_LOCATION");
    public static final long MAX_GAS_AMOUNT = PROPERTIES_CONFIGURATION.getLong("MAX_GAS_AMOUNT");
    public static final long GAS_UNIT_PRICE = PROPERTIES_CONFIGURATION.getLong("GAS_UNIT_PRICE");
    public static final long EXPIRATION_TIMESTAMP_SECS_OFFSET = PROPERTIES_CONFIGURATION.getLong(
            "EXPIRATION_TIMESTAMP_SECS_OFFSET");
    public static final long EXPIRATION_TIMESTAMP_SECS_OFFSET_ACCOUNT_CREATION = PROPERTIES_CONFIGURATION.getLong("EXPIRATION_TIMESTAMP_SECS_OFFSET_ACCOUNT_CREATION");
    public static final String ACCOUNT_FILE_LOCATION = PROPERTIES_CONFIGURATION.getString("ACCOUNT_FILE_LOCATION");
    public static final long DATABASE_SLEEP_TIME = PROPERTIES_CONFIGURATION.getLong("DATABASE_SLEEP_TIME");
    public static final boolean SINGLE_ACCOUNT_FOR_WORKLOAD = PROPERTIES_CONFIGURATION.getBoolean(
            "SINGLE_ACCOUNT_FOR_WORKLOAD");
    public static final int MAX_RETRIES_FAUCET = PROPERTIES_CONFIGURATION.getInt("MAX_RETRIES_FAUCET");
    public static final long WAIT_DURATION_MILLIS_FAUCET = PROPERTIES_CONFIGURATION.getLong("WAIT_DURATION_MILLIS_FAUCET");
    public static final int DEFAULT_TX_TIMEOUT_FAUCET = PROPERTIES_CONFIGURATION.getInt("DEFAULT_TX_TIMEOUT_FAUCET");
    public static final boolean CUSTOM_STATISTIC_GAS_USED_TX = PROPERTIES_CONFIGURATION.getBoolean("CUSTOM_STATISTIC_GAS_USED_TX");

    public static final long RUNTIME = PROPERTIES_CONFIGURATION.getLong("RUNTIME");
    public static final int NUMBER_OF_PREDEFINED_ACCOUNTS = PROPERTIES_CONFIGURATION.getInt("NUMBER_OF_PREDEFINED_ACCOUNTS");
    public static final boolean PRE_PREPARE_ACCOUNTS = PROPERTIES_CONFIGURATION.getBoolean("PRE_PREPARE_ACCOUNTS");

    public static final int TIMEOUT_TRANSACTION = PROPERTIES_CONFIGURATION.getInt("TIMEOUT_TRANSACTION");
    public static final int TIMEOUT_TRANSACTION_ACCOUNT_CREATION = PROPERTIES_CONFIGURATION.getInt(
            "TIMEOUT_TRANSACTION_ACCOUNT_CREATION");
    public static final int TIMEOUT_TRANSACTION_SEND = PROPERTIES_CONFIGURATION.getInt("TIMEOUT_TRANSACTION_SEND");
    public static final TimeUnit TIMEOUT_UNIT_TRANSACTION = PROPERTIES_CONFIGURATION.get(TimeUnit.class,
            "TIMEOUT_UNIT_TRANSACTION");
    public static final int PREPARE_THREAD_NUMBER = PROPERTIES_CONFIGURATION.getInt("PREPARE_THREAD_NUMBER");
    public static final boolean DROP_ON_TIMEOUT = PROPERTIES_CONFIGURATION.getBoolean("DROP_ON_TIMEOUT");
    public static final boolean ENABLE_BLOCK_STATISTICS = PROPERTIES_CONFIGURATION.getBoolean(
            "ENABLE_BLOCK_STATISTICS");
    public static final List<String> SERVERS_TO_READ_FROM = PROPERTIES_CONFIGURATION.getList(String.class, "SERVERS_TO_READ_FROM");

    public static Class<? extends IDiemPayloads> WRITE_PAYLOAD_PATTERN;

    public static Class<? extends IDiemPayloads> READ_PAYLOAD_PATTERN;

    public static final boolean PREPARE_WRITE_PAYLOADS = PROPERTIES_CONFIGURATION.getBoolean("PREPARE_WRITE_PAYLOADS");
    public static final boolean SEND_WRITE_ASYNC = PROPERTIES_CONFIGURATION.getBoolean("SEND_WRITE_ASYNC");
    public static final boolean SEND_WRITE_SYNC = PROPERTIES_CONFIGURATION.getBoolean("SEND_WRITE_SYNC");
    public static final boolean LISTENER_AS_THREAD = PROPERTIES_CONFIGURATION.getBoolean("LISTENER_AS_THREAD");
    public static final List<String> NODE_LIST = PROPERTIES_CONFIGURATION.getList(String.class, "NODE_LIST");
    public static final List<String> NODES_TO_SUBSCRIBE_TO_WS = PROPERTIES_CONFIGURATION.getList(String.class,
            "NODES_TO_SUBSCRIBE_TO_WS");
    public static final boolean RECEIVE_READ_REQUEST = PROPERTIES_CONFIGURATION.getBoolean("RECEIVE_READ_REQUEST");
    public static final double LISTENER_THRESHOLD = PROPERTIES_CONFIGURATION.getDouble("LISTENER_THRESHOLD");

    public static final long RECONNECTION_SLEEP_TIME = PROPERTIES_CONFIGURATION.getLong("RECONNECTION_SLEEP_TIME");
    public static final int MAX_CONNECTION_RETRIES = PROPERTIES_CONFIGURATION.getInt("MAX_CONNECTION_RETRIES");

    public static final double LISTENER_TOTAL_THRESHOLD = PROPERTIES_CONFIGURATION.getDouble(
            "LISTENER_TOTAL_THRESHOLD");
    public static final int NUMBER_OF_LISTENERS = (PROPERTIES_CONFIGURATION.getInt("NUMBER_OF_LISTENERS") == -1 ?
            GeneralConfiguration.CLIENT_COUNT :
            PROPERTIES_CONFIGURATION.getInt("NUMBER_OF_LISTENERS"));
    public static final boolean ENABLE_LISTENER = PROPERTIES_CONFIGURATION.getBoolean("ENABLE_LISTENER");
    public static final long TIMEOUT_LISTENER = PROPERTIES_CONFIGURATION.getLong("TIMEOUT_LISTENER");
    public static final TimeUnit TIMEOUT_LISTENER_TIME_UNIT = PROPERTIES_CONFIGURATION.get(TimeUnit.class,
            "TIMEOUT_LISTENER_TIME_UNIT");

    public static final boolean ENABLE_RATE_LIMITER_FOR_WRITE_PAYLOADS = PROPERTIES_CONFIGURATION.getBoolean(
            "ENABLE_RATE_LIMITER_FOR_WRITE_PAYLOADS");
    public static final List<Double> WRITE_PAYLOADS_PER_SECOND = PROPERTIES_CONFIGURATION.getList(Double.class,
            "WRITE_PAYLOADS_PER_SECOND");
    public static final boolean PREPARE_READ_PAYLOADS = PROPERTIES_CONFIGURATION.getBoolean("PREPARE_READ_PAYLOADS");
    public static final boolean ENABLE_RATE_LIMITER_FOR_READ_PAYLOADS = PROPERTIES_CONFIGURATION.getBoolean(
            "ENABLE_RATE_LIMITER_FOR_READ_PAYLOADS");
    public static final List<Double> READ_PAYLOADS_PER_SECOND = PROPERTIES_CONFIGURATION.getList(Double.class,
            "READ_PAYLOADS_PER_SECOND");
    public static final boolean RETURN_ON_EVENT_DUPLICATE = PROPERTIES_CONFIGURATION.getBoolean(
            "RETURN_ON_EVENT_DUPLICATE");
    public static final boolean SEND_WRITE_REQUESTS = PROPERTIES_CONFIGURATION.getBoolean("SEND_WRITE_REQUESTS");
    public static final boolean SEND_READ_REQUESTS = PROPERTIES_CONFIGURATION.getBoolean("SEND_READ_REQUESTS");
    public static final List<String> EVENT_EXISTS_SUFFIX_LIST = PROPERTIES_CONFIGURATION.getList(String.class,
            "EVENT_EXISTS_SUFFIX_LIST");
    public static final boolean HANDLE_EVENT_SYNCHRONIZED = PROPERTIES_CONFIGURATION.getBoolean(
            "HANDLE_EVENT_SYNCHRONIZED");

    public static final int SORT_ARRAY_LENGTH = PROPERTIES_CONFIGURATION.getInt("SORT_ARRAY_LENGTH");

    public static final int KEY_VALUE_STRING_LENGTH = PROPERTIES_CONFIGURATION.getInt("KEY_VALUE_STRING_LENGTH");

    public static final int LEN_OUTER_LOOP_MEMORY = PROPERTIES_CONFIGURATION.getInt("LEN_OUTER_LOOP_MEMORY");
    public static final int LEN_INNER_LOOP_MEMORY = PROPERTIES_CONFIGURATION.getInt("LEN_INNER_LOOP_MEMORY");
    public static final int FIRST_CHAR_INT_MEMORY = PROPERTIES_CONFIGURATION.getInt("FIRST_CHAR_INT_MEMORY");
    public static final int LENGTH_MEMORY = PROPERTIES_CONFIGURATION.getInt("LENGTH_MEMORY");

    public static final int START_RECURSION = PROPERTIES_CONFIGURATION.getInt("START_RECURSION");
    public static final int END_RECURSION = PROPERTIES_CONFIGURATION.getInt("END_RECURSION");

    public static final int START_LOOP = PROPERTIES_CONFIGURATION.getInt("START_LOOP");
    public static final int END_LOOP = PROPERTIES_CONFIGURATION.getInt("END_LOOP");

    public static final int SIZE_IO = PROPERTIES_CONFIGURATION.getInt("SIZE_IO");
    public static final int RET_LEN_IO = PROPERTIES_CONFIGURATION.getInt("RET_LEN_IO");

    public static final int CHECKING_BALANCE = PROPERTIES_CONFIGURATION.getInt("CHECKING_BALANCE");
    public static final int SAVINGS_BALANCE = PROPERTIES_CONFIGURATION.getInt("SAVINGS_BALANCE");
    public static final int WRITE_CHECK_AMOUNT = PROPERTIES_CONFIGURATION.getInt("WRITE_CHECK_AMOUNT");
    public static final int DEPOSIT_CHECK_AMOUNT = PROPERTIES_CONFIGURATION.getInt("DEPOSIT_CHECK_AMOUNT");
    public static final int TRANSACT_SAVINGS_AMOUNT = PROPERTIES_CONFIGURATION.getInt("TRANSACT_SAVINGS_AMOUNT");
    public static final int SEND_PAYMENT_AMOUNT = PROPERTIES_CONFIGURATION.getInt("SEND_PAYMENT_AMOUNT");
    public static final int SEND_CYCLE = PROPERTIES_CONFIGURATION.getInt("SEND_CYCLE");

    static {
        try {
            WRITE_PAYLOAD_PATTERN =
                    (Class<? extends IDiemPayloads>) Class.forName(PROPERTIES_CONFIGURATION.getString(
                            "WRITE_PAYLOAD_PATTERN"));
        } catch (ClassNotFoundException ex) {
            ExceptionHandler.logException(ex);
        }
    }

    static {
        try {
            READ_PAYLOAD_PATTERN = (Class<? extends IDiemPayloads>) Class.forName(PROPERTIES_CONFIGURATION.getString(
                    "READ_PAYLOAD_PATTERN"));
        } catch (ClassNotFoundException ex) {
            ExceptionHandler.logException(ex);
        }
    }

    static {
        try {
            WRITE_PAYLOAD = (Class<? extends IDiemWritePayload>) Class.forName(PROPERTIES_CONFIGURATION.getString(
                    "WRITE_PAYLOAD"));
        } catch (ClassNotFoundException ex) {
            ExceptionHandler.logException(ex);
        }
    }

    static {
        try {
            READ_PAYLOAD = (Class<? extends IDiemReadPayload>) Class.forName(PROPERTIES_CONFIGURATION.getString(
                    "READ_PAYLOAD"));
        } catch (ClassNotFoundException ex) {
            ExceptionHandler.logException(ex);
        }
    }

    static {
        GeneralConfiguration.notes = GeneralConfiguration.notes + " | " +
                (PROPERTIES_CONFIGURATION.getString("notes") == null ? "" : PROPERTIES_CONFIGURATION.getString("notes"
                ));
    }

    static {
        boolean potentialInconsistent = false;
        System.out.println("Checking for potential inconsistencies of the configuration...");
        System.out.println("Config potentially consistent: " + !potentialInconsistent);
    }

    private Configuration() {
    }

}
