package diem.payload_patterns;

import client.client.ClientObject;
import client.supplements.ExceptionHandler;
import client.utils.GenericSelectionStrategy;
import co.paralleluniverse.fibers.Suspendable;
import diem.configuration.Configuration;
import diem.payloads.IDiemReadPayload;
import org.apache.log4j.Logger;

import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;

public class DiemSingleReadPayload implements IDiemPayloads {

    private static final Logger LOG = Logger.getLogger(DiemSingleReadPayload.class);

    @Suspendable
    @SafeVarargs
    @Override
    public final <E> List<IDiemReadPayload> getPayloads(final E... params) {
        if (params.length == 1) {
            return preparePayloads((ClientObject) params[0]);
        }
        throw new IllegalArgumentException("Expecting exactly 1 argument for: " + this.getClass().getName());
    }

    @Suspendable
    @SafeVarargs
    private final <E> List<IDiemReadPayload> preparePayloads(final E... values) {

        List<IDiemReadPayload> payLoadList = new ArrayList<>();

        IDiemReadPayload iDiemReadPayload = null;
        try {
            iDiemReadPayload = Configuration.READ_PAYLOAD.getDeclaredConstructor().newInstance();
        } catch (InstantiationException | IllegalAccessException | InvocationTargetException | NoSuchMethodException ex) {
            ExceptionHandler.logException(ex);
        }

        Object[] payload = createPayload(
                (ClientObject) values[0]);

        Objects.requireNonNull(iDiemReadPayload).setValues(payload);

        payLoadList.add(iDiemReadPayload);

        iDiemReadPayload.setSpecificPayloadType("keyValue");

        return payLoadList;
    }

    @Suspendable
    private Object[] createPayload(final ClientObject clientObject) {

        List<String> servers = GenericSelectionStrategy.selectFixed(Configuration.SERVERS_TO_READ_FROM,
                Collections.singletonList(0), false);
        String address = servers.get(0);
        String txid = "e626c49e0e55da85a73bf59b16b4edbea80e27d8d6b13ed480a03eef935ba104";

        List<Object> values = new ArrayList<>();
        values.add(address);
        values.add(txid);

        return values.toArray();

    }

}
