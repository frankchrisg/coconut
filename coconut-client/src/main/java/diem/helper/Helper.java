package diem.helper;

import client.configuration.GeneralConfiguration;
import client.database.Connection;
import client.supplements.ExceptionHandler;
import co.paralleluniverse.fibers.Suspendable;
import com.diem.*;
import com.diem.jsonrpc.DiemJsonRpcClient;
import com.diem.jsonrpc.JsonRpc;
import com.diem.types.*;
import com.diem.utils.AccountAddressUtils;
import com.diem.utils.HashUtils;
import com.diem.utils.TransactionUtils;
import com.google.common.io.BaseEncoding;
import com.novi.bcs.BcsDeserializer;
import com.novi.serde.Bytes;
import com.novi.serde.DeserializationError;
import diem.configuration.Configuration;
import net.i2p.crypto.eddsa.Utils;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.bouncycastle.crypto.params.Ed25519PrivateKeyParameters;

import java.io.*;
import java.lang.reflect.Field;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.security.SecureRandom;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicLong;

import static com.diem.AccountIdentifier.NetworkPrefix.TestnetPrefix;

public class Helper {

    private static final Logger LOG = Logger.getLogger(Helper.class);

    private Helper() {
    }

    @Suspendable
    public static String reverseHex(final String originalHex) {
        if (originalHex.length() % 2 != 0) {
            throw new ArithmeticException("Hex parameter not even");
        }
        int lengthInBytes = originalHex.length() / 2;
        char[] chars = new char[lengthInBytes * 2];
        for (int i = 0; i < lengthInBytes; i++) {
            int reversedIndex = lengthInBytes - 1 - i;
            chars[reversedIndex * 2] = originalHex.charAt(i * 2);
            chars[reversedIndex * 2 + 1] = originalHex.charAt(i * 2 + 1);
        }
        return new String(chars);
    }

    @Suspendable
    public static PrivateKey getNewPrivateKey() {
        return new Ed25519PrivateKey(new Ed25519PrivateKeyParameters(new SecureRandom()));
    }

    @Suspendable
    public static Ed25519PrivateKey getMintKey(final String mintKeyFile) {
        return new Ed25519PrivateKey(Objects.requireNonNull(getMintKeyHex(mintKeyFile)));
    }

    @Suspendable
    public static String getMintKeyHex(final String mintKeyFile) {
        byte[] content;
        try {
            content = Files.readAllBytes(Paths.get(mintKeyFile));
            Bytes bytes = new BcsDeserializer(content).deserialize_bytes();
            return Utils.bytesToHex(bytes.content());
        } catch (IOException | DeserializationError ex) {
            ExceptionHandler.logException(ex);
        }
        return null;
    }

    @Suspendable
    public static byte[] getPrivateKeyData(final PrivateKey privateKey) {
        Field f;
        Ed25519PrivateKeyParameters privateKeyParameters = null;
        try {
            f = privateKey.getClass().getDeclaredField("key");
            f.setAccessible(true);
            privateKeyParameters = (Ed25519PrivateKeyParameters) f.get(privateKey);

            LOG.debug("Private key: " + Utils.bytesToHex(privateKeyParameters.getEncoded()) + " is private: " + privateKeyParameters.isPrivate());

        } catch (NoSuchFieldException | IllegalAccessException ex) {
            ExceptionHandler.logException(ex);
        }
        return Objects.requireNonNull(privateKeyParameters).getEncoded();
    }

    @Suspendable
    public static void writeAccountInformationToFile(final String fileName, final String privateKey,
                                                     final String publicKey,
                                                     final String accountAddress, final String authKey) {

        try (FileWriter writer = new FileWriter(fileName, true)) {
            writer.write(privateKey + " " + publicKey + " " + accountAddress + " " + authKey);
            writer.write("\n");
        } catch (IOException ex) {
            ExceptionHandler.logException(ex);
        }

    }

    @Suspendable
    public static List<AccountInformation> readAccountInformationFromFile(final File file) {
        try (BufferedReader bufferedReader = new BufferedReader(new FileReader(file))) {

            List<AccountInformation> accountInformationList = new ArrayList<>();

            String line = bufferedReader.readLine();
            while (line != null) {
                AccountInformation accountInformation = null;
                String[] splitLine = line.split(" ");
                if (splitLine.length == 4) {
                    accountInformation = new AccountInformation(splitLine[0], splitLine[1],
                            splitLine[2], splitLine[3]);
                } else {
                    LOG.error("Unexpected length: " + splitLine.length);
                }
                LOG.debug("Current line: " + line);
                line = bufferedReader.readLine();
                accountInformationList.add(accountInformation);
                //LOG.debug("Line: " + line);
            }

            for (final AccountInformation accountInformation : accountInformationList) {
                LOG.debug("Private key: " + accountInformation.getPrivateKey() + " Public key: " + accountInformation.getPublicKey() + " Account address: " + accountInformation.getAccountAddress()
                        + " Auth key:" + accountInformation.getAuthKey());
            }

            return accountInformationList;
        } catch (IOException ex) {
            ExceptionHandler.logException(ex);
        }
        return null;
    }

    @Suspendable
    public static byte[] loadMintKey(final String keyLocation) {
        try {
            return Files.readAllBytes(Paths.get(keyLocation));
        } catch (IOException ex) {
            ExceptionHandler.logException(ex);
        }
        return null;
    }

    @Suspendable
    public static String getEncodedMintKey(final byte[] mintKey) {
        return Utils.bytesToHex(mintKey);
    }

    @Suspendable
    public static String getPublicKeyForMintKey(final byte[] mintKey) {
        Bytes bytes;
        try {
            bytes = new BcsDeserializer(mintKey).deserialize_bytes();
            Ed25519PrivateKey ed25519PrivateKey = new Ed25519PrivateKey(Utils.bytesToHex(bytes.content()));
            return BaseEncoding.base16().encode(ed25519PrivateKey.publicKey());
        } catch (DeserializationError ex) {
            ExceptionHandler.logException(ex);
        }
        return "";
    }

    @Suspendable
    public static JsonRpc.Account getAccount(final DiemClient client, final String address) {
        try {
            return client.getAccount(address);
        } catch (DiemException ex) {
            ExceptionHandler.logException(ex);
        }
        return null;
    }

    @Suspendable
    public static long getSequenceNumber(final JsonRpc.Account account) {
        return account.getSequenceNumber();
    }

    @Suspendable
    public static String createIntentIdentifier(final AccountAddress accountAddress, final long amount) {
        AccountIdentifier accountIdentifier = new AccountIdentifier(TestnetPrefix, accountAddress);
        IntentIdentifier intentIdentifier = new IntentIdentifier(accountIdentifier,
                Configuration.DEFAULT_CURRENCY_CODE, amount);
        return intentIdentifier.encode();
    }

    @Suspendable
    public static IntentIdentifier decodeIntentIdentifier(final String intentIdentifier) {
        return IntentIdentifier.decode(TestnetPrefix, intentIdentifier);
    }

    @Suspendable
    public static RawTransaction getRawTransaction(final AccountAddress accountAddress, final long sequenceNumber,
                                                   final TransactionPayload payload, final long maxGasAmount,
                                                   final long gasUnitPrice,
                                                   final String currencyCode,
                                                   final long expirationTimestampSecsOffset, final ChainId chainId) {
        return new RawTransaction(accountAddress, sequenceNumber, payload, maxGasAmount, gasUnitPrice,
                currencyCode, (System.currentTimeMillis() / 1000) + expirationTimestampSecsOffset, chainId);
    }

    @Suspendable
    public static SignedTransaction signTransaction(final PrivateKey privateKey, final RawTransaction rawTransaction) {
        return Signer.sign(privateKey, rawTransaction);
    }

    @Suspendable
    public static boolean checkTransactionValidity(final SignedTransaction signedTransaction,
                                                   final JsonRpc.Transaction transaction,
                                                   final PrivateKey privateKey) {
        if (HashUtils.transactionHash(signedTransaction).equals(transaction.getHash().toUpperCase())) {
            LOG.trace("Hash matches");
            if (transaction.getTransaction().getSignature().equals(Utils.bytesToHex(new Ed25519Signature(new Bytes(privateKey.sign(HashUtils.signatureMessage(signedTransaction.raw_txn)))).value.content()))) {
                LOG.trace("Signature matches");
            } else {
                return false;
            }
        } else {
            return false;
        }

        LOG.debug("Tx: " + transaction.getHash() + " status: " + transaction.getVmStatus().getType());
        return TransactionUtils.isExecuted(transaction);
    }

    /*@Suspendable
    public void addEvent(final DiemClient client, final AccountAddress address, final int offset) {
        try {
            String hexString = String.format("%016x", client.getAccount(address).getSequenceNumber() + offset);
            String key = Helper.reverseHex(hexString) + address;
            ListenObject listenObject = new ListenObject();
            listenObject.setKey(key);
            //Events.getObservableList().add(listenObject);
        } catch (DiemException ex) {
            ExceptionHandler.logException(ex);
        }
    }*/

    @Suspendable
    public static synchronized AtomicLong getNonce(final DiemClient client, final String address) throws Exception {
        long sequenceNumber = client.getAccount(AccountAddressUtils.create(address)).getSequenceNumber();
        LOG.debug(address + " Address | Nonce: " + sequenceNumber);
        return new AtomicLong(sequenceNumber);
    }

    @Suspendable
    public static byte[] intToBytes(final int intToBytes) {
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        ObjectOutput out;
        byte[] int_bytes = new byte[0];
        try {
            out = new ObjectOutputStream(bos);
            out.writeInt(intToBytes);
            out.close();
            int_bytes = bos.toByteArray();
            bos.close();
        } catch (IOException ex) {
            ExceptionHandler.logException(ex);
        }
        return int_bytes;
    }

    @Suspendable
    public static synchronized AtomicLong setNonceFor(final DiemClient client, final String address) {

        AtomicLong nonce = null;
        try {
            nonce = getNonce(client, address);

            if (Configuration.DISTRIBUTED_NONCE_HANDLING) {

                try (java.sql.Connection connection = Connection.getConnection()) {
                    String query = "INSERT INTO diem_nonce AS dn (address, nonce)" +
                            "VALUES (?, ?)" +
                            "ON CONFLICT (address) DO NOTHING " +
                            "RETURNING nonce";

                    PreparedStatement preparedStatement = connection.prepareStatement(query);
                    preparedStatement.setString(1, address);
                    preparedStatement.setLong(2, nonce.get());

                    ResultSet resultSet = preparedStatement.executeQuery();

                    int i = 0;
                    while (resultSet.next()) {
                        LOG.info("Current nonce: " + resultSet.getInt("nonce"));
                        i++;
                    }
                    if (i == 0) {
                        LOG.info("Result set was empty");
                    }

                    resultSet.close();
                    preparedStatement.close();
                } catch (SQLException ex) {
                    ExceptionHandler.logException(ex);
                }
            }
        } catch (Exception ex) {
            ExceptionHandler.logException(ex);
        }
        return nonce;
    }

    @Suspendable
    public static boolean deleteAccountFile(final String filePath) {
        return new File(filePath).delete();
    }

    @Suspendable
    public static long getLatestVersion(final DiemJsonRpcClient diemJsonRpcClient, final long offset) {
        JsonRpc.Metadata metadata = null;
        try {
            metadata = diemJsonRpcClient.getMetadata();
        } catch (DiemException ex) {
            ExceptionHandler.logException(ex);
        }
        return (Objects.requireNonNull(metadata).getVersion() + offset);
    }

    @Suspendable
    public static long getLatestVersion(final DiemJsonRpcClient diemJsonRpcClient) {
        return getLatestVersion(diemJsonRpcClient, 0);
    }

    @Suspendable
    public synchronized static long updateNonceRange(final String address, final long startSequenceNumber,
                                                     final int range,
                                                     final AtomicInteger rangeCounter, final AtomicLong currentParam) {
        final long current = currentParam.get();
        if (current == 0) {
            return handleNonceRange(address, startSequenceNumber, range, rangeCounter, currentParam);
        } else if (rangeCounter.get() >= range) {
            return nonceRangeUpdateOutOfBounds(address, startSequenceNumber);
        } else {
            rangeCounter.getAndIncrement();
            long updateNonce = currentParam.incrementAndGet();
            LOG.debug("Nonce for range in: " + updateNonce);
            return updateNonce;
        }
    }

    @Suspendable
    private static long nonceRangeUpdateOutOfBounds(final String address, final long startSequenceNumber) {
        long updateNonce = updateNonce(address, startSequenceNumber);
        LOG.debug("Nonce for range out of bounds: " + updateNonce);
        return updateNonce;
    }

    @Suspendable
    private static long handleNonceRange(final String address, final long startSequenceNumber, final int range,
                                         final AtomicInteger rangeCounter, final AtomicLong currentParam) {
        long updateNonceRange = updateNonceRange(address, startSequenceNumber, range);
        rangeCounter.getAndIncrement();
        currentParam.set(updateNonceRange);
        LOG.debug("Nonce for range start: " + updateNonceRange);
        return updateNonceRange;
    }

    @Suspendable
    public static long updateNonceRange(final String address, final long startSequenceNumber, final int range) {
        long nonce = 0;
        try (java.sql.Connection connection = client.database.Connection.getConnection()) {

            String query = "INSERT INTO diem_nonce AS dn (address, nonce)" +
                    "VALUES (?, ?)" +
                    "ON CONFLICT (address) DO UPDATE " +
                    "SET nonce = dn.nonce + ? " +
                    "RETURNING nonce";

            PreparedStatement preparedStatement = connection.prepareStatement(query);
            preparedStatement.setString(1, address);
            preparedStatement.setLong(2, startSequenceNumber);
            preparedStatement.setLong(3, range);
            ResultSet resultSet = preparedStatement.executeQuery();

            while (resultSet.next()) {
                LOG.info("New nonce (range): " + (resultSet.getInt("nonce")));
                nonce = resultSet.getLong("nonce");
            }

            resultSet.close();
            preparedStatement.close();
        } catch (SQLException ex) {
            ExceptionHandler.logException(ex);
        }
        return (nonce == startSequenceNumber ? startSequenceNumber : nonce - range + 1);
    }

    @Suspendable
    public static long updateNonce(final String address, final long startSequenceNumber) {
        long nonce = 0;
        try (java.sql.Connection connection = client.database.Connection.getConnection()) {

            String query = "INSERT INTO diem_nonce AS dn (address, nonce)" +
                    "VALUES (?, ?)" +
                    "ON CONFLICT (address) DO UPDATE " +
                    "SET nonce = dn.nonce + 1 " +
                    "RETURNING nonce";

            PreparedStatement preparedStatement = connection.prepareStatement(query);
            preparedStatement.setString(1, address);
            preparedStatement.setLong(2, startSequenceNumber);
            ResultSet resultSet = preparedStatement.executeQuery();

            while (resultSet.next()) {
                LOG.info("New nonce: " + (resultSet.getInt("nonce")));
                nonce = resultSet.getLong("nonce");
            }

            resultSet.close();
            preparedStatement.close();
        } catch (SQLException ex) {
            ExceptionHandler.logException(ex);
        }
        return nonce;
    }

    private static final String ACCOUNT_PREFIX = "11110";
    private static final String DUMMY_AUTH_KEY = "DUMMY_AUTH_KEY";
    private static final int ACCOUNT_PADDING = 10000000;

    @Suspendable
    public static void preparePredefinedAccountsFile(final String fileName) {

        String privateKey = getMintKeyHex(Configuration.MINT_KEY_LOCATION);
        Ed25519PrivateKey mintKey = getMintKey(Configuration.MINT_KEY_LOCATION);
        String publicKey = Utils.bytesToHex(mintKey.publicKey());

        try (FileWriter writer = new FileWriter(fileName, true)) {
            try (BufferedWriter bufferedWriter = new BufferedWriter(writer)) {
                for (int i = Integer.parseInt(GeneralConfiguration.HOST_ID.split("-")[6]); i <= Integer.parseInt(GeneralConfiguration.HOST_ID.split("-")[7]); i++) {
                    String accountWithSuffix = ACCOUNT_PREFIX + i;
                    String formattedAccount = StringUtils.leftPad(accountWithSuffix, 32, '1');
                    LOG.debug(privateKey + " " + publicKey + " " + formattedAccount + " " + DUMMY_AUTH_KEY);
                    bufferedWriter.write(privateKey + " " + publicKey + " " + formattedAccount + " " + DUMMY_AUTH_KEY);
                    bufferedWriter.write("\n");
                }
            }
        } catch (IOException ex) {
            ExceptionHandler.logException(ex);
        }
    }

}
