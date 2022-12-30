package diem.helper.json.blockData;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import javax.annotation.Generated;
import java.util.List;

@Generated("jsonschema2pojo")
public class Result {

    @SerializedName("version")
    @Expose
    private int version;
    @SerializedName("transaction")
    @Expose
    private Transaction transaction;
    @SerializedName("hash")
    @Expose
    private String hash;
    @SerializedName("bytes")
    @Expose
    private String bytes;
    @SerializedName("events")
    @Expose
    private List<Event> events = null;
    @SerializedName("vm_status")
    @Expose
    private VmStatus vmStatus;
    @SerializedName("gas_used")
    @Expose
    private int gasUsed;

    public int getVersion() {
        return version;
    }

    public void setVersion(int version) {
        this.version = version;
    }

    public Transaction getTransaction() {
        return transaction;
    }

    public void setTransaction(Transaction transaction) {
        this.transaction = transaction;
    }

    public String getHash() {
        return hash;
    }

    public void setHash(String hash) {
        this.hash = hash;
    }

    public String getBytes() {
        return bytes;
    }

    public void setBytes(String bytes) {
        this.bytes = bytes;
    }

    public List<Event> getEvents() {
        return events;
    }

    public void setEvents(List<Event> events) {
        this.events = events;
    }

    public VmStatus getVmStatus() {
        return vmStatus;
    }

    public void setVmStatus(VmStatus vmStatus) {
        this.vmStatus = vmStatus;
    }

    public int getGasUsed() {
        return gasUsed;
    }

    public void setGasUsed(int gasUsed) {
        this.gasUsed = gasUsed;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(Result.class.getName()).append('@').append(Integer.toHexString(System.identityHashCode(this))).append('[');
        sb.append("version");
        sb.append('=');
        sb.append(this.version);
        sb.append(',');
        sb.append("transaction");
        sb.append('=');
        sb.append(((this.transaction == null) ? "<null>" : this.transaction));
        sb.append(',');
        sb.append("hash");
        sb.append('=');
        sb.append(((this.hash == null) ? "<null>" : this.hash));
        sb.append(',');
        sb.append("bytes");
        sb.append('=');
        sb.append(((this.bytes == null) ? "<null>" : this.bytes));
        sb.append(',');
        sb.append("events");
        sb.append('=');
        sb.append(((this.events == null) ? "<null>" : this.events));
        sb.append(',');
        sb.append("vmStatus");
        sb.append('=');
        sb.append(((this.vmStatus == null) ? "<null>" : this.vmStatus));
        sb.append(',');
        sb.append("gasUsed");
        sb.append('=');
        sb.append(this.gasUsed);
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
        result = ((result * 31) + this.gasUsed);
        result = ((result * 31) + ((this.bytes == null) ? 0 : this.bytes.hashCode()));
        result = ((result * 31) + this.version);
        result = ((result * 31) + ((this.vmStatus == null) ? 0 : this.vmStatus.hashCode()));
        result = ((result * 31) + ((this.transaction == null) ? 0 : this.transaction.hashCode()));
        result = ((result * 31) + ((this.hash == null) ? 0 : this.hash.hashCode()));
        result = ((result * 31) + ((this.events == null) ? 0 : this.events.hashCode()));
        return result;
    }

    @Override
    public boolean equals(Object other) {
        if (other == this) {
            return true;
        }
        if ((other instanceof Result) == false) {
            return false;
        }
        Result rhs = ((Result) other);
        return (((((((this.gasUsed == rhs.gasUsed) && ((this.bytes == rhs.bytes) || ((this.bytes != null) && this.bytes.equals(rhs.bytes)))) && (this.version == rhs.version)) && ((this.vmStatus == rhs.vmStatus) || ((this.vmStatus != null) && this.vmStatus.equals(rhs.vmStatus)))) && ((this.transaction == rhs.transaction) || ((this.transaction != null) && this.transaction.equals(rhs.transaction)))) && ((this.hash == rhs.hash) || ((this.hash != null) && this.hash.equals(rhs.hash)))) && ((this.events == rhs.events) || ((this.events != null) && this.events.equals(rhs.events))));
    }

}
