package diem.helper.json.blockData;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import javax.annotation.Generated;

@Generated("jsonschema2pojo")
public class Transaction {

    @SerializedName("type")
    @Expose
    private String type;
    @SerializedName("timestamp_usecs")
    @Expose
    private long timestampUsecs;

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public long getTimestampUsecs() {
        return timestampUsecs;
    }

    public void setTimestampUsecs(long timestampUsecs) {
        this.timestampUsecs = timestampUsecs;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(Transaction.class.getName()).append('@').append(Integer.toHexString(System.identityHashCode(this))).append('[');
        sb.append("type");
        sb.append('=');
        sb.append(((this.type == null) ? "<null>" : this.type));
        sb.append(',');
        sb.append("timestampUsecs");
        sb.append('=');
        sb.append(this.timestampUsecs);
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
        result = ((result * 31) + ((this.type == null) ? 0 : this.type.hashCode()));
        result = ((result * 31) + ((int) (this.timestampUsecs ^ (this.timestampUsecs >>> 32))));
        return result;
    }

    @Override
    public boolean equals(Object other) {
        if (other == this) {
            return true;
        }
        if ((other instanceof Transaction) == false) {
            return false;
        }
        Transaction rhs = ((Transaction) other);
        return (((this.type == rhs.type) || ((this.type != null) && this.type.equals(rhs.type))) && (this.timestampUsecs == rhs.timestampUsecs));
    }

}