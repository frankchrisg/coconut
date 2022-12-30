package diem.helper.json.blockData;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import javax.annotation.Generated;

@Generated("jsonschema2pojo")
public class Event {

    @SerializedName("key")
    @Expose
    private String key;
    @SerializedName("sequence_number")
    @Expose
    private int sequenceNumber;
    @SerializedName("transaction_version")
    @Expose
    private int transactionVersion;
    @SerializedName("data")
    @Expose
    private Data data;

    public String getKey() {
        return key;
    }

    public void setKey(String key) {
        this.key = key;
    }

    public int getSequenceNumber() {
        return sequenceNumber;
    }

    public void setSequenceNumber(int sequenceNumber) {
        this.sequenceNumber = sequenceNumber;
    }

    public int getTransactionVersion() {
        return transactionVersion;
    }

    public void setTransactionVersion(int transactionVersion) {
        this.transactionVersion = transactionVersion;
    }

    public Data getData() {
        return data;
    }

    public void setData(Data data) {
        this.data = data;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(Event.class.getName()).append('@').append(Integer.toHexString(System.identityHashCode(this))).append('[');
        sb.append("key");
        sb.append('=');
        sb.append(((this.key == null) ? "<null>" : this.key));
        sb.append(',');
        sb.append("sequenceNumber");
        sb.append('=');
        sb.append(this.sequenceNumber);
        sb.append(',');
        sb.append("transactionVersion");
        sb.append('=');
        sb.append(this.transactionVersion);
        sb.append(',');
        sb.append("data");
        sb.append('=');
        sb.append(((this.data == null) ? "<null>" : this.data));
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
        result = ((result * 31) + this.sequenceNumber);
        result = ((result * 31) + this.transactionVersion);
        result = ((result * 31) + ((this.data == null) ? 0 : this.data.hashCode()));
        result = ((result * 31) + ((this.key == null) ? 0 : this.key.hashCode()));
        return result;
    }

    @Override
    public boolean equals(Object other) {
        if (other == this) {
            return true;
        }
        if ((other instanceof Event) == false) {
            return false;
        }
        Event rhs = ((Event) other);
        return ((((this.sequenceNumber == rhs.sequenceNumber) && (this.transactionVersion == rhs.transactionVersion)) && ((this.data == rhs.data) || ((this.data != null) && this.data.equals(rhs.data)))) && ((this.key == rhs.key) || ((this.key != null) && this.key.equals(rhs.key))));
    }

}
