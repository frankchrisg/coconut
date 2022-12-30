package diem.payload_patterns.smallbank;

import client.client.ClientObject;
import client.supplements.ExceptionHandler;
import co.paralleluniverse.fibers.Suspendable;
import com.diem.types.TypeTag;
import diem.configuration.Configuration;
import diem.helper.AccountInformation;
import diem.helper.AccountStore;
import diem.payload_patterns.IDiemPayloads;
import diem.payloads.IDiemWritePayload;
import org.apache.commons.lang3.RandomStringUtils;
import org.apache.commons.lang3.tuple.ImmutablePair;
import org.apache.log4j.Logger;

import java.lang.reflect.InvocationTargetException;
import java.util.*;
import java.util.concurrent.atomic.AtomicInteger;

public class DiemUniformSbBalancePayload implements IDiemPayloads {

    private static final Logger LOG = Logger.getLogger(DiemUniformSbBalancePayload.class);

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

            Objects.requireNonNull(iDiemWritePayload).setValuesWithArgsAsString(objectList);//.setValues(objectList);
            Objects.requireNonNull(iDiemWritePayload).setSignature(payload.getRight());

            payLoadList.add(iDiemWritePayload);
        }

        return payLoadList;
    }

    private static final AtomicInteger REQUEST_COUNTER = new AtomicInteger(0);

    @Suspendable
    private ImmutablePair<Object[], String> createPayload(final ClientObject clientObject, final int i,
                                                          final IDiemWritePayload iDiemWritePayload) {

        int id = REQUEST_COUNTER.getAndIncrement();
        AccountInformation accountInformationSender = ACCOUNT_INFORMATION_LIST_UNMODIFIABLE.get(id);
        //int id = REQUEST_COUNTER.incrementAndGet();
        String signature = System.currentTimeMillis() + RandomStringUtils.random(12, true, true);

        // global start id (string) - offset (host) (string) - local id (int)
        ////String prefix = GeneralConfiguration.RUN_ID.split("-")[0] + "-" + GeneralConfiguration.HOST_ID + "-" + id;

        iDiemWritePayload.setSenderAccountInformation(accountInformationSender);

        List<TypeTag> typeTags = new ArrayList<>();
        /*List<Bytes> args =
                Stream.of(TraitHelpers.encode_u8vector_argument(Bytes.valueOf(signature.getBytes()))
                ).collect(Collectors.toList());*/

        Map<TypeTag, List<String>> argsMap = new LinkedHashMap<>();
        List<String> paramList = new ArrayList<>();
        paramList.add(accountInformationSender.getAccountAddress());
        paramList.add(signature);
        argsMap.put(new TypeTag.Vector(new TypeTag.U8()), paramList);

        String function = "balance";
        String identifier = "SmallBank";

        List<Object> values = new ArrayList<>();
        values.add(typeTags);
        values.add(argsMap);
        values.add(function);
        values.add(identifier);

        iDiemWritePayload.setValueToRead(null);
        iDiemWritePayload.setEventPrefix("balance ");
        iDiemWritePayload.setSpecificPayloadType("balance");

        return ImmutablePair.of(values.toArray(), signature);
    }

}
