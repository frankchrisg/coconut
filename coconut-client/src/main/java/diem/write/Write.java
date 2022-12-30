package diem.write;

import client.configuration.GeneralConfiguration;
import client.supplements.ExceptionHandler;
import co.paralleluniverse.fibers.Suspendable;
import com.diem.DiemClient;
import com.diem.PrivateKey;
import com.diem.jsonrpc.DiemTransactionWaitTimeoutException;
import com.diem.jsonrpc.JsonRpc;
import com.diem.types.SignedTransaction;
import diem.configuration.Configuration;
import diem.helper.Helper;
import diem.statistics.CustomStatisticObject;
import diem.statistics.WriteStatisticObject;
import org.apache.commons.lang3.tuple.ImmutablePair;
import org.apache.log4j.Logger;
import org.hibernate.cfg.NotYetImplementedException;

public class Write implements IWritingMethod {

    private static final Logger LOG = Logger.getLogger(Write.class);

    @SafeVarargs
    @Suspendable
    @Override
    public final <E> ImmutablePair<Boolean, String> write(final E... params) {
        if (params.length == 5) {

            DiemClient client = (DiemClient) params[0];
            SignedTransaction signedTransaction = (SignedTransaction) params[1];
            PrivateKey privateKey = (PrivateKey) params[2];
            WriteStatisticObject writeStatisticObject = (WriteStatisticObject) params[3];
            CustomStatisticObject<String> customStatisticObject = (CustomStatisticObject<String>) params[4];

            return write(client, signedTransaction, privateKey, writeStatisticObject, customStatisticObject);
        } else {
            throw new NotYetImplementedException("Not yet implemented, extend as needed");
        }
    }

    @Suspendable
    private ImmutablePair<Boolean, String> write(final DiemClient client, final SignedTransaction signedTransaction,
                                                 final PrivateKey privateKey,
                                                 final WriteStatisticObject writeStatisticObject,
                                                 final CustomStatisticObject<String> customStatisticObject) {
        writeStatisticObject.setStartTime(System.nanoTime());

        try {
            client.submit(signedTransaction);

            if (Configuration.SEND_WRITE_SYNC) {

                JsonRpc.Transaction transaction = client.waitForTransaction(signedTransaction,
                        Configuration.TIMEOUT_TRANSACTION_SEND);

                if(Configuration.CUSTOM_STATISTIC_GAS_USED_TX) {
                    customStatisticObject.setSharedId("gas_used_diem_tx");
                    customStatisticObject.setId(writeStatisticObject.getClientId() + "-" + writeStatisticObject.getRequestId() + "-" + writeStatisticObject.getRequestNumber());
                    customStatisticObject.setValue(transaction.getGasUsed());
                }

                if (Configuration.CHECK_TRANSACTION_VALIDITY) {
                    boolean isValid = Helper.checkTransactionValidity(signedTransaction, transaction, privateKey);
                    if (!isValid) {
                        LOG.error("Transaction verification failed");
                        writeStatisticObject.setEndTime(GeneralConfiguration.DEFAULT_ERROR_TIMESTAMP);
                        return ImmutablePair.of(true, "Transaction verification failed");
                    }
                }

                LOG.info("Write, txid: " + transaction.getHash());
                writeStatisticObject.setEndTime(System.nanoTime());

            } else if (Configuration.SEND_WRITE_ASYNC) {
                LOG.debug("Sent async");
                writeStatisticObject.setEndTime(-1);
            } else {
                throw new NotYetImplementedException("Not yet implemented");
            }
            return ImmutablePair.of(false, "");
        } catch (DiemTransactionWaitTimeoutException ex) {
            ExceptionHandler.logException(ex);
            writeStatisticObject.setEndTime(GeneralConfiguration.DEFAULT_ERROR_TIMESTAMP);
            return new ImmutablePair<>(true, "TIMEOUT_EX");
        } catch (/*todo specify concrete exception(s) DiemException | StaleResponseException */ Exception ex) {
            ExceptionHandler.logException(ex);
            writeStatisticObject.setEndTime(GeneralConfiguration.DEFAULT_ERROR_TIMESTAMP);
            return ImmutablePair.of(true, ex.getMessage());
        }
    }

}
