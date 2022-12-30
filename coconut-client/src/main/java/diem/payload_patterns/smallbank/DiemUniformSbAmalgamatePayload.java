package diem.payload_patterns.smallbank;

import client.client.ClientObject;
import client.configuration.GeneralConfiguration;
import client.supplements.ExceptionHandler;
import co.paralleluniverse.fibers.Suspendable;
import com.diem.types.TypeTag;
import diem.configuration.Configuration;
import diem.helper.AccountInformation;
import diem.helper.AccountStore;
import diem.payload_patterns.IDiemPayloads;
import diem.payloads.IDiemWritePayload;
import org.apache.commons.lang3.RandomStringUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.tuple.ImmutablePair;
import org.apache.log4j.Logger;

import java.lang.reflect.InvocationTargetException;
import java.util.*;
import java.util.concurrent.atomic.AtomicInteger;

public class DiemUniformSbAmalgamatePayload implements IDiemPayloads {

    private static final Logger LOG = Logger.getLogger(DiemUniformSbAmalgamatePayload.class);

    // private static final String DUMMY_ADDRESS = "0000000000000000000000000b1e55ed";
    private static final List<AccountInformation> ACCOUNT_INFORMATION_LIST_UNMODIFIABLE =
            AccountStore.getAccountInformationListUnmodifiable(Configuration.ACCOUNT_FILE_LOCATION);

    @Suspendable
    @SafeVarargs
    @Override
    public final <E> List<IDiemWritePayload> getPayloads(final E... params) {
        if (params.length == 2) {
            return preparePayloads((ClientObject) params[0], params[1]);
        }
        throw new IllegalArgumentException("Expecting exactly 2 argument for: " + this.getClass().getName());
    }

    @Suspendable
    @SafeVarargs
    private final <E> List<IDiemWritePayload> preparePayloads(final E... values) {

        List<IDiemWritePayload> payLoadList = new ArrayList<>();

        for (int i = 0; i < (Integer) values[1]; i++) {

            IDiemWritePayload iDiemWritePayload = null;
            try {
                iDiemWritePayload = Configuration.WRITE_PAYLOAD.getDeclaredConstructor().newInstance();
            } catch (InstantiationException | IllegalAccessException | InvocationTargetException | NoSuchMethodException ex) {
                ExceptionHandler.logException(ex);
            }

            ImmutablePair<Object[], String> payload = createPayload(
                    (ClientObject) values[0], i, Objects.requireNonNull(iDiemWritePayload));
            Object[] objectList = payload.getLeft();

            Objects.requireNonNull(iDiemWritePayload).setValuesWithArgsAsString(objectList);
            Objects.requireNonNull(iDiemWritePayload).setSignature(payload.getRight());

            payLoadList.add(iDiemWritePayload);
        }

        return payLoadList;
    }

    private static final AtomicInteger REQUEST_COUNTER = new AtomicInteger(0);

    @Suspendable
    private ImmutablePair<Object[], String> createPayload(final ClientObject clientObject, final int i,
                                                          final IDiemWritePayload iDiemWritePayload) {

        int id = REQUEST_COUNTER.updateAndGet(value -> (value % Configuration.SEND_CYCLE == 0) ? 1 : value + 1);

        if(Configuration.SEND_CYCLE > (GeneralConfiguration.CLIENT_COUNT * GeneralConfiguration.CLIENT_WORKLOADS.get(0)
                * Configuration.NUMBER_OF_TRANSACTIONS_PER_CLIENT)) {
            LOG.error("More cycles than accounts available");
            //System.exit(1);
        }
        if(!Configuration.PRE_PREPARE_ACCOUNTS) {
            LOG.error("Use prepared accounts for payload");
            System.exit(1);
        }

        String signature = System.currentTimeMillis() + RandomStringUtils.random(12, true, true);

        String prefix_destination;
        AccountInformation accountInformationSender;
        AccountInformation accountInformationDestination;
        if(id % Configuration.SEND_CYCLE == 0) {
            accountInformationSender = ACCOUNT_INFORMATION_LIST_UNMODIFIABLE.get(id - 1);
            accountInformationDestination = ACCOUNT_INFORMATION_LIST_UNMODIFIABLE.get(0);
            //prefix_destination = getPreparedAccount(0);
            prefix_destination = ACCOUNT_INFORMATION_LIST_UNMODIFIABLE.get(0).getAccountAddress();
            LOG.debug("Reset id destination: " + prefix_destination);
        } else {
            accountInformationSender = ACCOUNT_INFORMATION_LIST_UNMODIFIABLE.get(id - 1);
            accountInformationDestination = ACCOUNT_INFORMATION_LIST_UNMODIFIABLE.get(id);
            prefix_destination = ACCOUNT_INFORMATION_LIST_UNMODIFIABLE.get(id).getAccountAddress(); //getPreparedAccount(id);
        }

        iDiemWritePayload.setReceiverAddresses(Collections.singletonList(accountInformationDestination.getAccountAddress()));
        iDiemWritePayload.setSenderAccountInformation(accountInformationSender);
        iDiemWritePayload.setReceiverAccountInformation(accountInformationDestination);

        List<TypeTag> typeTags = new ArrayList<>();

        Map<TypeTag, List<String>> argsMap = new LinkedHashMap<>();
        //argsMap.put(new TypeTag.Address(), DUMMY_ADDRESS);
        argsMap.put(new TypeTag.Address(), Collections.singletonList(prefix_destination));
        argsMap.put(new TypeTag.Vector(new TypeTag.U8()), Collections.singletonList(signature));

        String function = "amalgamate";
        String identifier = "SmallBank";

        List<Object> values = new ArrayList<>();
        values.add(typeTags);
        values.add(argsMap);
        values.add(function);
        values.add(identifier);

        iDiemWritePayload.setValueToRead(null);
        iDiemWritePayload.setEventPrefix("amalgamate ");
        iDiemWritePayload.setSpecificPayloadType("amalgamate");

        return ImmutablePair.of(values.toArray(), signature);
    }

    private static final String ACCOUNT_PREFIX = "11110";

    @Suspendable
    public static String getPreparedAccount(final int id) {
        String accountWithSuffix = ACCOUNT_PREFIX + id;
        return StringUtils.leftPad(accountWithSuffix, 32, '1');
    }

}
