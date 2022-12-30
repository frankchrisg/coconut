package diem.connection;

import client.supplements.ExceptionHandler;
import co.paralleluniverse.fibers.SuspendExecution;
import co.paralleluniverse.fibers.Suspendable;
import co.paralleluniverse.strands.Strand;
import com.diem.DiemClient;
import com.diem.DiemException;
import com.diem.jsonrpc.*;
import com.diem.types.ChainId;
import diem.configuration.Configuration;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.log4j.Logger;

public class Client {

    private static final Logger LOG = Logger.getLogger(Client.class);

    @Suspendable
    public DiemClient createClient(final int maxRetries, final long waitDurationMillis, final Long keepAliveTimeout,
                                   final String jsonRpcUrl, final ChainId chainId) {
        boolean hasError;
        int i = 0;

        Retry<Response> retry = new Retry<>(maxRetries, waitDurationMillis, StaleResponseException.class);
        CloseableHttpClient build =
                HttpClients.custom().setKeepAliveStrategy((response, context) -> keepAliveTimeout).build();
        DiemJsonRpcClient diemJsonRpcClient = new DiemJsonRpcClient(jsonRpcUrl, build, chainId, retry);

        do {
            try {
                JsonRpc.Metadata metadata = diemJsonRpcClient.getMetadata();
                LOG.debug("Metadata: " + metadata);
                hasError = false;
            } catch (DiemException ex) {
                ExceptionHandler.logException(ex);
                hasError = true;
            }
            if (hasError) {
                try {
                    Strand.sleep(Configuration.RECONNECTION_SLEEP_TIME);
                } catch (SuspendExecution | InterruptedException exception) {
                    ExceptionHandler.logException(exception);
                } finally {
                    i++;
                }
            }
        } while (hasError && i < Configuration.MAX_CONNECTION_RETRIES);

        return diemJsonRpcClient;
    }

}
