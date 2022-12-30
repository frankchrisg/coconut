package diem.helper;

import co.paralleluniverse.fibers.Suspendable;
import diem.payloads.IDiemWritePayload;
import org.apache.log4j.Logger;

import java.util.Collections;
import java.util.List;

public class PayloadHelper {

    private static final Logger LOG = Logger.getLogger(PayloadHelper.class);

    private PayloadHelper() {
    }

    //private static final AtomicInteger REQUEST_COUNTER = new AtomicInteger(0);

    @Suspendable
    public static void handlePayload(final IDiemWritePayload writePayload, final List<String> addressList,
                                     final String accountAddress) {
        if ("sendPayment".equals(writePayload.getSpecificPayloadType()) || "amalgamate".equals(writePayload.getSpecificPayloadType())) {

            int addressPosition = addressList.indexOf(accountAddress) == addressList.size() - 1 ? 0 :
                    addressList.indexOf(accountAddress) + 1;
            writePayload.setReceiverAddresses(Collections.singletonList(
                    addressList.get(addressPosition)));
            LOG.debug("Sender: " + accountAddress + " Destination: " + addressList.get(addressPosition));

            /*while (true) {
                if (Configuration.SEND_CYCLE > (GeneralConfiguration.CLIENT_COUNT * GeneralConfiguration
                .CLIENT_WORKLOADS.get(0)
                        * Configuration.NUMBER_OF_TRANSACTIONS_PER_CLIENT)) {
                    LOG.error("More cycles than accounts available, aborting");
                    System.exit(1);
                }

                int id = REQUEST_COUNTER.updateAndGet(value -> (value % Configuration.SEND_CYCLE == 0) ? 1 : value + 1);

                if (id % Configuration.SEND_CYCLE == 0) {
                    LOG.info("Reset id destination: " + 0 + " sender: " + id);
                    id = 0;
                }

                if (!addressList.get(id).equals(accountAddress)) {
                    return id;
                } else {
                    LOG.trace("Same addresses detected");
                }

            }*/

        }

    }
}
