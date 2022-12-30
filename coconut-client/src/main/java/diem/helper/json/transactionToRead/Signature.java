package diem.helper.json.transactionToRead;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import javax.annotation.Generated;

@Generated("jsonschema2pojo")
public class Signature {

    @SerializedName("type")
    @Expose
    private String type;
    @SerializedName("public_key")
    @Expose
    private String publicKey;
    @SerializedName("signature")
    @Expose
    private String signature;

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getPublicKey() {
        return publicKey;
    }

    public void setPublicKey(String publicKey) {
        this.publicKey = publicKey;
    }

    public String getSignature() {
        return signature;
    }

    public void setSignature(String signature) {
        this.signature = signature;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(Signature.class.getName()).append('@').append(Integer.toHexString(System.identityHashCode(this))).append('[');
        sb.append("type");
        sb.append('=');
        sb.append(((this.type == null) ? "<null>" : this.type));
        sb.append(',');
        sb.append("publicKey");
        sb.append('=');
        sb.append(((this.publicKey == null) ? "<null>" : this.publicKey));
        sb.append(',');
        sb.append("signature");
        sb.append('=');
        sb.append(((this.signature == null) ? "<null>" : this.signature));
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
        result = ((result * 31) + ((this.publicKey == null) ? 0 : this.publicKey.hashCode()));
        result = ((result * 31) + ((this.type == null) ? 0 : this.type.hashCode()));
        result = ((result * 31) + ((this.signature == null) ? 0 : this.signature.hashCode()));
        return result;
    }

    @Override
    public boolean equals(Object other) {
        if (other == this) {
            return true;
        }
        if ((other instanceof Signature) == false) {
            return false;
        }
        Signature rhs = ((Signature) other);
        return ((((this.publicKey == rhs.publicKey) || ((this.publicKey != null) && this.publicKey.equals(rhs.publicKey))) && ((this.type == rhs.type) || ((this.type != null) && this.type.equals(rhs.type)))) && ((this.signature == rhs.signature) || ((this.signature != null) && this.signature.equals(rhs.signature))));
    }

}
