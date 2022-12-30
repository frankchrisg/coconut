package diem.payload_patterns.memory;

import client.client.ClientObject;
import client.supplements.ExceptionHandler;
import co.paralleluniverse.fibers.Suspendable;
import com.diem.types.TypeTag;
import com.novi.serde.Bytes;
import diem.configuration.Configuration;
import diem.helper.TraitHelpers;
import diem.payload_patterns.IDiemPayloads;
import diem.payloads.IDiemWritePayload;
import org.apache.commons.lang3.RandomStringUtils;
import org.apache.commons.lang3.tuple.ImmutablePair;
import org.apache.log4j.Logger;

import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class DiemUniformMemoryPayload implements IDiemPayloads {

    private static final Logger LOG = Logger.getLogger(DiemUniformMemoryPayload.class);

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

            Objects.requireNonNull(iDiemWritePayload).setValues(objectList);
            Objects.requireNonNull(iDiemWritePayload).setSignature(payload.getRight());

            payLoadList.add(iDiemWritePayload);
        }

        return payLoadList;
    }

    @Suspendable
    private ImmutablePair<Object[], String> createPayload(final ClientObject clientObject, final int i,
                                                          final IDiemWritePayload iDiemWritePayload) {

        String signature = System.currentTimeMillis() + RandomStringUtils.random(12, true, true);

        List<TypeTag> typeTags = new ArrayList<>();
        List<Bytes> args =
                Stream.of(TraitHelpers.encode_u64_argument((long) Configuration.LEN_OUTER_LOOP_MEMORY),
                        TraitHelpers.encode_u64_argument((long) Configuration.LEN_INNER_LOOP_MEMORY),
                        TraitHelpers.encode_u64_argument((long) Configuration.FIRST_CHAR_INT_MEMORY),
                        TraitHelpers.encode_u64_argument((long) Configuration.LENGTH_MEMORY),
                        TraitHelpers.encode_u8vector_argument(Bytes.valueOf(signature.getBytes()))
                ).collect(Collectors.toList());
        String function = "memory";
        String identifier = "Memory";

        List<Object> values = new ArrayList<>();
        values.add(typeTags);
        values.add(args);
        values.add(function);
        values.add(identifier);

        iDiemWritePayload.setValueToRead(null);
        iDiemWritePayload.setEventPrefix("memory ");
        iDiemWritePayload.setSpecificPayloadType("memory");

        return ImmutablePair.of(values.toArray(), signature);
    }

}
