package diem.helper.json.blockData;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import javax.annotation.Generated;

@Generated("jsonschema2pojo")
public class Data {

    @SerializedName("type")
    @Expose
    private String type;
    @SerializedName("round")
    @Expose
    private int round;
    @SerializedName("proposer")
    @Expose
    private String proposer;
    @SerializedName("proposed_time")
    @Expose
    private long proposedTime;

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public int getRound() {
        return round;
    }

    public void setRound(int round) {
        this.round = round;
    }

    public String getProposer() {
        return proposer;
    }

    public void setProposer(String proposer) {
        this.proposer = proposer;
    }

    public long getProposedTime() {
        return proposedTime;
    }

    public void setProposedTime(long proposedTime) {
        this.proposedTime = proposedTime;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(Data.class.getName()).append('@').append(Integer.toHexString(System.identityHashCode(this))).append('[');
        sb.append("type");
        sb.append('=');
        sb.append(((this.type == null) ? "<null>" : this.type));
        sb.append(',');
        sb.append("round");
        sb.append('=');
        sb.append(this.round);
        sb.append(',');
        sb.append("proposer");
        sb.append('=');
        sb.append(((this.proposer == null) ? "<null>" : this.proposer));
        sb.append(',');
        sb.append("proposedTime");
        sb.append('=');
        sb.append(this.proposedTime);
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
        result = ((result * 31) + ((int) (this.proposedTime ^ (this.proposedTime >>> 32))));
        result = ((result * 31) + ((this.type == null) ? 0 : this.type.hashCode()));
        result = ((result * 31) + this.round);
        result = ((result * 31) + ((this.proposer == null) ? 0 : this.proposer.hashCode()));
        return result;
    }

    @Override
    public boolean equals(Object other) {
        if (other == this) {
            return true;
        }
        if ((other instanceof Data) == false) {
            return false;
        }
        Data rhs = ((Data) other);
        return ((((this.proposedTime == rhs.proposedTime) && ((this.type == rhs.type) || ((this.type != null) && this.type.equals(rhs.type)))) && (this.round == rhs.round)) && ((this.proposer == rhs.proposer) || ((this.proposer != null) && this.proposer.equals(rhs.proposer))));
    }

}
