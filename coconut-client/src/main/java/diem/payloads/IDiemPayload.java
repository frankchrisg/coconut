package diem.payloads;

import client.commoninterfaces.IBlockchainPayload;

public interface IDiemPayload extends IBlockchainPayload {

    <E> E getPayload(E... params);

    String getSpecificPayloadType();

    void setSpecificPayloadType(String type);

}
