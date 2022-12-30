package diem.read;

import client.configuration.GeneralConfiguration;
import client.supplements.ExceptionHandler;
import co.paralleluniverse.fibers.Suspendable;
import com.google.gson.Gson;
import diem.configuration.Configuration;
import diem.helper.json.transactionToRead.TransactionToRead;
import diem.payloads.IDiemReadPayload;
import diem.statistics.ReadStatisticObject;
import okhttp3.Call;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import org.apache.commons.lang3.tuple.ImmutablePair;
import org.apache.log4j.Logger;
import org.hibernate.cfg.NotYetImplementedException;

import java.io.IOException;
import java.util.Objects;

public class Read implements IReadingMethod {

    private static final Logger LOG = Logger.getLogger(Read.class);

    @SafeVarargs
    @Suspendable
    @Override
    public final <E> E read(final E... params) {
        if (params.length == 2) {

            IDiemReadPayload iDiemReadPayload = (IDiemReadPayload) params[0];
            String[] payload = iDiemReadPayload.getPayload();
            String address = payload[0];
            String txid = payload[1];
            ReadStatisticObject readStatisticObject = (ReadStatisticObject) params[1];

            return (E) read(address, txid, readStatisticObject);
        } else {
            throw new NotYetImplementedException("Not yet implemented, extend as needed");
        }
    }

    @Suspendable
    private ImmutablePair<Boolean, String> read(final String address, final String txid,
                                                final ReadStatisticObject readStatisticObject) {

        readStatisticObject.setStartTime(System.nanoTime());

        OkHttpClient client = new OkHttpClient.Builder()
                .build();

        Request request = new Request.Builder()
                .url(address + txid)
                .build();

        Call call = client.newCall(request);

        try {
            Response response = call.execute();
            if (Configuration.RECEIVE_READ_REQUEST) {
                String responseBody = Objects.requireNonNull(response.body()).string();
                TransactionToRead transactionToRead = new Gson().fromJson(responseBody, TransactionToRead.class);

                if (!transactionToRead.isSuccess() || !"Executed successfully".equals(transactionToRead.getVmStatus())) {
                    readStatisticObject.setEndTime(GeneralConfiguration.DEFAULT_ERROR_TIMESTAMP);
                    return ImmutablePair.of(true, responseBody);
                }

                LOG.info("Message: " + response.message() + " Body: " + responseBody);
                readStatisticObject.setEndTime(System.nanoTime());
                return ImmutablePair.of(false, responseBody);
            } else {
                readStatisticObject.setEndTime(-1);
                return ImmutablePair.of(false, "");
            }
        } catch (IOException ex) {
            ExceptionHandler.logException(ex);
            readStatisticObject.setEndTime(GeneralConfiguration.DEFAULT_ERROR_TIMESTAMP);
            return ImmutablePair.of(true, ex.getMessage());
        }
    }

}
