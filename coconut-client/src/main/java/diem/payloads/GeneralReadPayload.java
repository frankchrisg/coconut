package diem.payloads;

import org.apache.log4j.Logger;

public class GeneralReadPayload implements IDiemReadPayload {

    private static final Logger LOG = Logger.getLogger(GeneralReadPayload.class);

    public String getAddress() {
        return address;
    }

    public void setAddress(final String address) {
        this.address = address;
    }

    public String getTxid() {
        return txid;
    }

    public void setTxid(final String txid) {
        this.txid = txid;
    }

    private String address;
    private String txid;

    @SafeVarargs
    @Override
    public final <E> E getPayload(final E... params) {
        return (E) new String[]{address, txid};
        //return (E) this;
    }

    @SafeVarargs
    @Override
    public final <E> void setValues(final E... params) {
        this.address = (String) params[0];
        this.txid = (String) params[1];
    }

    private String specificPayloadType;

    @Override
    public String getSpecificPayloadType() {
        return specificPayloadType;
    }

    @Override
    public void setSpecificPayloadType(final String specificPayloadType) {
        this.specificPayloadType = specificPayloadType;
    }

}
