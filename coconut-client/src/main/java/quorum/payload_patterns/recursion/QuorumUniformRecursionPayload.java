package quorum.payload_patterns.recursion;

import client.client.ClientObject;
import client.supplements.ExceptionHandler;
import co.paralleluniverse.fibers.Suspendable;
import org.apache.commons.lang3.RandomStringUtils;
import org.apache.commons.lang3.tuple.ImmutablePair;
import org.apache.log4j.Logger;
import org.web3j.abi.TypeReference;
import org.web3j.abi.datatypes.Type;
import org.web3j.abi.datatypes.Uint;
import org.web3j.abi.datatypes.Utf8String;
import quorum.configuration.Configuration;
import quorum.payload_patterns.IQuorumPayloads;
import quorum.payloads.IQuorumWritePayload;

import java.lang.reflect.InvocationTargetException;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

public class QuorumUniformRecursionPayload implements IQuorumPayloads {

    private static final Logger LOG = Logger.getLogger(QuorumUniformRecursionPayload.class);

    @SafeVarargs
    @Override
    @Suspendable
    public final <E> List<IQuorumWritePayload> getPayloads(final E... params) {
        if (params.length == 2) {
            return preparePayloads((ClientObject) params[0], params[1]);
        }
        throw new IllegalArgumentException("Expecting exactly 2 arguments for: " + this.getClass().getName());
    }

    @SafeVarargs
    @Suspendable
    private final <E> List<IQuorumWritePayload> preparePayloads(final E... values) {

        List<IQuorumWritePayload> payLoadList = new ArrayList<>();

        for (int i = 0; i < (Integer) values[1]; i++) {
            IQuorumWritePayload iQuorumWritePayload = null;
            try {
                iQuorumWritePayload = Configuration.WRITE_PAYLOAD.getDeclaredConstructor().newInstance();
            } catch (InstantiationException | IllegalAccessException | InvocationTargetException | NoSuchMethodException ex) {
                ExceptionHandler.logException(ex);
            }

            ImmutablePair<Object[], String> payload = createPayload(
                    (ClientObject) values[0], i, Objects.requireNonNull(iQuorumWritePayload));
            Object[] objectList = payload.getLeft();

            Objects.requireNonNull(iQuorumWritePayload).setValues(objectList);
            Objects.requireNonNull(iQuorumWritePayload).setSignature(payload.getRight());

            payLoadList.add(iQuorumWritePayload);
        }

        return payLoadList;
    }

    @Suspendable
    private ImmutablePair<Object[], String> createPayload(final ClientObject clientObject, final int i,
                                                          final IQuorumWritePayload iQuorumWritePayload) {

        String signature = System.currentTimeMillis() + RandomStringUtils.random(12, true, true);

        String function = "main";
        List<Type<?>> inputs = new ArrayList<>();
        if(Configuration.START_RECURSION > Configuration.END_RECURSION) {
            LOG.error("Start > End");
        }
        inputs.add(new Uint(BigInteger.valueOf(Configuration.START_RECURSION)));
        inputs.add(new Uint(BigInteger.valueOf(Configuration.END_RECURSION)));
        inputs.add(new Utf8String(signature));
        List<TypeReference<?>> outputs = new ArrayList<>();
        //outputs.add(TypeReference.create(Utf8String.class));

        List<Object> values = new ArrayList<>();
        values.add(function);
        values.add(inputs);
        values.add(outputs);

        iQuorumWritePayload.setValueToRead(null);
        iQuorumWritePayload.setEventPrefix("recursion");
        iQuorumWritePayload.setSpecificPayloadType("recursion");

        return ImmutablePair.of(values.toArray(), signature);

    }

}
