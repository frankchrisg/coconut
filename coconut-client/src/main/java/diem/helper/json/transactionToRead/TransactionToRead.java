package diem.helper.json.transactionToRead;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import javax.annotation.Generated;
import java.util.List;

@Generated("jsonschema2pojo")
public class TransactionToRead {

    @SerializedName("type")
    @Expose
    private String type;
    @SerializedName("version")
    @Expose
    private String version;
    @SerializedName("hash")
    @Expose
    private String hash;
    @SerializedName("state_root_hash")
    @Expose
    private String stateRootHash;
    @SerializedName("event_root_hash")
    @Expose
    private String eventRootHash;
    @SerializedName("gas_used")
    @Expose
    private String gasUsed;
    @SerializedName("success")
    @Expose
    private boolean success;
    @SerializedName("vm_status")
    @Expose
    private String vmStatus;
    @SerializedName("sender")
    @Expose
    private String sender;
    @SerializedName("sequence_number")
    @Expose
    private String sequenceNumber;
    @SerializedName("max_gas_amount")
    @Expose
    private String maxGasAmount;
    @SerializedName("gas_unit_price")
    @Expose
    private String gasUnitPrice;
    @SerializedName("gas_currency_code")
    @Expose
    private String gasCurrencyCode;
    @SerializedName("expiration_timestamp_secs")
    @Expose
    private String expirationTimestampSecs;
    @SerializedName("payload")
    @Expose
    private Payload payload;
    @SerializedName("signature")
    @Expose
    private Signature signature;
    @SerializedName("events")
    @Expose
    private List<Event> events = null;

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getVersion() {
        return version;
    }

    public void setVersion(String version) {
        this.version = version;
    }

    public String getHash() {
        return hash;
    }

    public void setHash(String hash) {
        this.hash = hash;
    }

    public String getStateRootHash() {
        return stateRootHash;
    }

    public void setStateRootHash(String stateRootHash) {
        this.stateRootHash = stateRootHash;
    }

    public String getEventRootHash() {
        return eventRootHash;
    }

    public void setEventRootHash(String eventRootHash) {
        this.eventRootHash = eventRootHash;
    }

    public String getGasUsed() {
        return gasUsed;
    }

    public void setGasUsed(String gasUsed) {
        this.gasUsed = gasUsed;
    }

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public String getVmStatus() {
        return vmStatus;
    }

    public void setVmStatus(String vmStatus) {
        this.vmStatus = vmStatus;
    }

    public String getSender() {
        return sender;
    }

    public void setSender(String sender) {
        this.sender = sender;
    }

    public String getSequenceNumber() {
        return sequenceNumber;
    }

    public void setSequenceNumber(String sequenceNumber) {
        this.sequenceNumber = sequenceNumber;
    }

    public String getMaxGasAmount() {
        return maxGasAmount;
    }

    public void setMaxGasAmount(String maxGasAmount) {
        this.maxGasAmount = maxGasAmount;
    }

    public String getGasUnitPrice() {
        return gasUnitPrice;
    }

    public void setGasUnitPrice(String gasUnitPrice) {
        this.gasUnitPrice = gasUnitPrice;
    }

    public String getGasCurrencyCode() {
        return gasCurrencyCode;
    }

    public void setGasCurrencyCode(String gasCurrencyCode) {
        this.gasCurrencyCode = gasCurrencyCode;
    }

    public String getExpirationTimestampSecs() {
        return expirationTimestampSecs;
    }

    public void setExpirationTimestampSecs(String expirationTimestampSecs) {
        this.expirationTimestampSecs = expirationTimestampSecs;
    }

    public Payload getPayload() {
        return payload;
    }

    public void setPayload(Payload payload) {
        this.payload = payload;
    }

    public Signature getSignature() {
        return signature;
    }

    public void setSignature(Signature signature) {
        this.signature = signature;
    }

    public List<Event> getEvents() {
        return events;
    }

    public void setEvents(List<Event> events) {
        this.events = events;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(TransactionToRead.class.getName()).append('@').append(Integer.toHexString(System.identityHashCode(this))).append('[');
        sb.append("type");
        sb.append('=');
        sb.append(((this.type == null) ? "<null>" : this.type));
        sb.append(',');
        sb.append("version");
        sb.append('=');
        sb.append(((this.version == null) ? "<null>" : this.version));
        sb.append(',');
        sb.append("hash");
        sb.append('=');
        sb.append(((this.hash == null) ? "<null>" : this.hash));
        sb.append(',');
        sb.append("stateRootHash");
        sb.append('=');
        sb.append(((this.stateRootHash == null) ? "<null>" : this.stateRootHash));
        sb.append(',');
        sb.append("eventRootHash");
        sb.append('=');
        sb.append(((this.eventRootHash == null) ? "<null>" : this.eventRootHash));
        sb.append(',');
        sb.append("gasUsed");
        sb.append('=');
        sb.append(((this.gasUsed == null) ? "<null>" : this.gasUsed));
        sb.append(',');
        sb.append("success");
        sb.append('=');
        sb.append(this.success);
        sb.append(',');
        sb.append("vmStatus");
        sb.append('=');
        sb.append(((this.vmStatus == null) ? "<null>" : this.vmStatus));
        sb.append(',');
        sb.append("sender");
        sb.append('=');
        sb.append(((this.sender == null) ? "<null>" : this.sender));
        sb.append(',');
        sb.append("sequenceNumber");
        sb.append('=');
        sb.append(((this.sequenceNumber == null) ? "<null>" : this.sequenceNumber));
        sb.append(',');
        sb.append("maxGasAmount");
        sb.append('=');
        sb.append(((this.maxGasAmount == null) ? "<null>" : this.maxGasAmount));
        sb.append(',');
        sb.append("gasUnitPrice");
        sb.append('=');
        sb.append(((this.gasUnitPrice == null) ? "<null>" : this.gasUnitPrice));
        sb.append(',');
        sb.append("gasCurrencyCode");
        sb.append('=');
        sb.append(((this.gasCurrencyCode == null) ? "<null>" : this.gasCurrencyCode));
        sb.append(',');
        sb.append("expirationTimestampSecs");
        sb.append('=');
        sb.append(((this.expirationTimestampSecs == null) ? "<null>" : this.expirationTimestampSecs));
        sb.append(',');
        sb.append("payload");
        sb.append('=');
        sb.append(((this.payload == null) ? "<null>" : this.payload));
        sb.append(',');
        sb.append("signature");
        sb.append('=');
        sb.append(((this.signature == null) ? "<null>" : this.signature));
        sb.append(',');
        sb.append("events");
        sb.append('=');
        sb.append(((this.events == null) ? "<null>" : this.events));
        sb.append(',');
        if (sb.charAt((sb.length() - 1)) == ',') {
            sb.setCharAt((sb.length() - 1), ']');
        } else {
            sb.append(']');
        }
        return sb.toString();
    }

    @Override
    public int hashCode() {
        int result = 1;
        result = ((result * 31) + ((this.sequenceNumber == null) ? 0 : this.sequenceNumber.hashCode()));
        result = ((result * 31) + ((this.signature == null) ? 0 : this.signature.hashCode()));
        result = ((result * 31) + ((this.eventRootHash == null) ? 0 : this.eventRootHash.hashCode()));
        result = ((result * 31) + ((this.gasCurrencyCode == null) ? 0 : this.gasCurrencyCode.hashCode()));
        result = ((result * 31) + ((this.type == null) ? 0 : this.type.hashCode()));
        result = ((result * 31) + ((this.version == null) ? 0 : this.version.hashCode()));
        result = ((result * 31) + ((this.stateRootHash == null) ? 0 : this.stateRootHash.hashCode()));
        result = ((result * 31) + ((this.vmStatus == null) ? 0 : this.vmStatus.hashCode()));
        result = ((result * 31) + ((this.expirationTimestampSecs == null) ? 0 :
                this.expirationTimestampSecs.hashCode()));
        result = ((result * 31) + ((this.gasUsed == null) ? 0 : this.gasUsed.hashCode()));
        result = ((result * 31) + ((this.sender == null) ? 0 : this.sender.hashCode()));
        result = ((result * 31) + ((this.payload == null) ? 0 : this.payload.hashCode()));
        result = ((result * 31) + (this.success ? 1 : 0));
        result = ((result * 31) + ((this.gasUnitPrice == null) ? 0 : this.gasUnitPrice.hashCode()));
        result = ((result * 31) + ((this.maxGasAmount == null) ? 0 : this.maxGasAmount.hashCode()));
        result = ((result * 31) + ((this.hash == null) ? 0 : this.hash.hashCode()));
        result = ((result * 31) + ((this.events == null) ? 0 : this.events.hashCode()));
        return result;
    }

    @Override
    public boolean equals(Object other) {
        if (other == this) {
            return true;
        }
        if ((other instanceof TransactionToRead) == false) {
            return false;
        }
        TransactionToRead rhs = ((TransactionToRead) other);
        return ((((((((((((((((((this.sequenceNumber == rhs.sequenceNumber) || ((this.sequenceNumber != null) && this.sequenceNumber.equals(rhs.sequenceNumber))) && ((this.signature == rhs.signature) || ((this.signature != null) && this.signature.equals(rhs.signature)))) && ((this.eventRootHash == rhs.eventRootHash) || ((this.eventRootHash != null) && this.eventRootHash.equals(rhs.eventRootHash)))) && ((this.gasCurrencyCode == rhs.gasCurrencyCode) || ((this.gasCurrencyCode != null) && this.gasCurrencyCode.equals(rhs.gasCurrencyCode)))) && ((this.type == rhs.type) || ((this.type != null) && this.type.equals(rhs.type)))) && ((this.version == rhs.version) || ((this.version != null) && this.version.equals(rhs.version)))) && ((this.stateRootHash == rhs.stateRootHash) || ((this.stateRootHash != null) && this.stateRootHash.equals(rhs.stateRootHash)))) && ((this.vmStatus == rhs.vmStatus) || ((this.vmStatus != null) && this.vmStatus.equals(rhs.vmStatus)))) && ((this.expirationTimestampSecs == rhs.expirationTimestampSecs) || ((this.expirationTimestampSecs != null) && this.expirationTimestampSecs.equals(rhs.expirationTimestampSecs)))) && ((this.gasUsed == rhs.gasUsed) || ((this.gasUsed != null) && this.gasUsed.equals(rhs.gasUsed)))) && ((this.sender == rhs.sender) || ((this.sender != null) && this.sender.equals(rhs.sender)))) && ((this.payload == rhs.payload) || ((this.payload != null) && this.payload.equals(rhs.payload)))) && (this.success == rhs.success)) && ((this.gasUnitPrice == rhs.gasUnitPrice) || ((this.gasUnitPrice != null) && this.gasUnitPrice.equals(rhs.gasUnitPrice)))) && ((this.maxGasAmount == rhs.maxGasAmount) || ((this.maxGasAmount != null) && this.maxGasAmount.equals(rhs.maxGasAmount)))) && ((this.hash == rhs.hash) || ((this.hash != null) && this.hash.equals(rhs.hash)))) && ((this.events == rhs.events) || ((this.events != null) && this.events.equals(rhs.events))));
    }

}
