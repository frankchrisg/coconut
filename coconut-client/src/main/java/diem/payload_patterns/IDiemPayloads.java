package diem.payload_patterns;

import co.paralleluniverse.fibers.Suspendable;
import diem.payloads.IDiemPayload;

import java.util.List;

public interface IDiemPayloads {

    @Suspendable
    <E> List<? extends IDiemPayload> getPayloads(E... params);

}
