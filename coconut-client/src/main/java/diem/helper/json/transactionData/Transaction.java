package diem.helper.json.transactionData;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import javax.annotation.Generated;

@Generated("jsonschema2pojo")
public class Transaction {

    @SerializedName("type")
    @Expose
    private String type;
    @SerializedName("sender")
    @Expose
    private String sender;
    @SerializedName("signature_scheme")
    @Expose
    private String signatureScheme;
    @SerializedName("signature")
    @Expose
    private String signature;
    @SerializedName("public_key")
    @Expose
    private String publicKey;
    @SerializedName("sequence_number")
    @Expose
    private int sequenceNumber;
    @SerializedName("chain_id")
    @Expose
    private int chainId;
    @SerializedName("max_gas_amount")
    @Expose
    private int maxGasAmount;
    @SerializedName("gas_unit_price")
    @Expose
    private int gasUnitPrice;
    @SerializedName("gas_currency")
    @Expose
    private String gasCurrency;
    @SerializedName("expiration_timestamp_secs")
    @Expose
    private int expirationTimestampSecs;
    @SerializedName("script_hash")
    @Expose
    private String scriptHash;
    @SerializedName("script_bytes")
    @Expose
    private String scriptBytes;
    @SerializedName("script")
    @Expose
    private Script script;

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getSender() {
        return sender;
    }

    public void setSender(String sender) {
        this.sender = sender;
    }

    public String getSignatureScheme() {
        return signatureScheme;
    }

    public void setSignatureScheme(String signatureScheme) {
        this.signatureScheme = signatureScheme;
    }

    public String getSignature() {
        return signature;
    }

    public void setSignature(String signature) {
        this.signature = signature;
    }

    public String getPublicKey() {
        return publicKey;
    }

    public void setPublicKey(String publicKey) {
        this.publicKey = publicKey;
    }

    public int getSequenceNumber() {
        return sequenceNumber;
    }

    public void setSequenceNumber(int sequenceNumber) {
        this.sequenceNumber = sequenceNumber;
    }

    public int getChainId() {
        return chainId;
    }

    public void setChainId(int chainId) {
        this.chainId = chainId;
    }

    public int getMaxGasAmount() {
        return maxGasAmount;
    }

    public void setMaxGasAmount(int maxGasAmount) {
        this.maxGasAmount = maxGasAmount;
    }

    public int getGasUnitPrice() {
        return gasUnitPrice;
    }

    public void setGasUnitPrice(int gasUnitPrice) {
        this.gasUnitPrice = gasUnitPrice;
    }

    public String getGasCurrency() {
        return gasCurrency;
    }

    public void setGasCurrency(String gasCurrency) {
        this.gasCurrency = gasCurrency;
    }

    public int getExpirationTimestampSecs() {
        return expirationTimestampSecs;
    }

    public void setExpirationTimestampSecs(int expirationTimestampSecs) {
        this.expirationTimestampSecs = expirationTimestampSecs;
    }

    public String getScriptHash() {
        return scriptHash;
    }

    public void setScriptHash(String scriptHash) {
        this.scriptHash = scriptHash;
    }

    public String getScriptBytes() {
        return scriptBytes;
    }

    public void setScriptBytes(String scriptBytes) {
        this.scriptBytes = scriptBytes;
    }

    public Script getScript() {
        return script;
    }

    public void setScript(Script script) {
        this.script = script;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(Transaction.class.getName()).append('@').append(Integer.toHexString(System.identityHashCode(this))).append('[');
        sb.append("type");
        sb.append('=');
        sb.append(((this.type == null) ? "<null>" : this.type));
        sb.append(',');
        sb.append("sender");
        sb.append('=');
        sb.append(((this.sender == null) ? "<null>" : this.sender));
        sb.append(',');
        sb.append("signatureScheme");
        sb.append('=');
        sb.append(((this.signatureScheme == null) ? "<null>" : this.signatureScheme));
        sb.append(',');
        sb.append("signature");
        sb.append('=');
        sb.append(((this.signature == null) ? "<null>" : this.signature));
        sb.append(',');
        sb.append("publicKey");
        sb.append('=');
        sb.append(((this.publicKey == null) ? "<null>" : this.publicKey));
        sb.append(',');
        sb.append("sequenceNumber");
        sb.append('=');
        sb.append(this.sequenceNumber);
        sb.append(',');
        sb.append("chainId");
        sb.append('=');
        sb.append(this.chainId);
        sb.append(',');
        sb.append("maxGasAmount");
        sb.append('=');
        sb.append(this.maxGasAmount);
        sb.append(',');
        sb.append("gasUnitPrice");
        sb.append('=');
        sb.append(this.gasUnitPrice);
        sb.append(',');
        sb.append("gasCurrency");
        sb.append('=');
        sb.append(((this.gasCurrency == null) ? "<null>" : this.gasCurrency));
        sb.append(',');
        sb.append("expirationTimestampSecs");
        sb.append('=');
        sb.append(this.expirationTimestampSecs);
        sb.append(',');
        sb.append("scriptHash");
        sb.append('=');
        sb.append(((this.scriptHash == null) ? "<null>" : this.scriptHash));
        sb.append(',');
        sb.append("scriptBytes");
        sb.append('=');
        sb.append(((this.scriptBytes == null) ? "<null>" : this.scriptBytes));
        sb.append(',');
        sb.append("script");
        sb.append('=');
        sb.append(((this.script == null) ? "<null>" : this.script));
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
        result = ((result * 31) + ((this.signature == null) ? 0 : this.signature.hashCode()));
        result = ((result * 31) + ((this.publicKey == null) ? 0 : this.publicKey.hashCode()));
        result = ((result * 31) + ((this.type == null) ? 0 : this.type.hashCode()));
        result = ((result * 31) + ((this.script == null) ? 0 : this.script.hashCode()));
        result = ((result * 31) + ((this.signatureScheme == null) ? 0 : this.signatureScheme.hashCode()));
        result = ((result * 31) + ((this.gasCurrency == null) ? 0 : this.gasCurrency.hashCode()));
        result = ((result * 31) + this.expirationTimestampSecs);
        result = ((result * 31) + ((this.sender == null) ? 0 : this.sender.hashCode()));
        result = ((result * 31) + this.chainId);
        result = ((result * 31) + ((this.scriptHash == null) ? 0 : this.scriptHash.hashCode()));
        result = ((result * 31) + this.gasUnitPrice);
        result = ((result * 31) + this.maxGasAmount);
        result = ((result * 31) + ((this.scriptBytes == null) ? 0 : this.scriptBytes.hashCode()));
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
        return ((((((((((((((this.sequenceNumber == rhs.sequenceNumber) && ((this.signature == rhs.signature) || ((this.signature != null) && this.signature.equals(rhs.signature)))) && ((this.publicKey == rhs.publicKey) || ((this.publicKey != null) && this.publicKey.equals(rhs.publicKey)))) && ((this.type == rhs.type) || ((this.type != null) && this.type.equals(rhs.type)))) && ((this.script == rhs.script) || ((this.script != null) && this.script.equals(rhs.script)))) && ((this.signatureScheme == rhs.signatureScheme) || ((this.signatureScheme != null) && this.signatureScheme.equals(rhs.signatureScheme)))) && ((this.gasCurrency == rhs.gasCurrency) || ((this.gasCurrency != null) && this.gasCurrency.equals(rhs.gasCurrency)))) && (this.expirationTimestampSecs == rhs.expirationTimestampSecs)) && ((this.sender == rhs.sender) || ((this.sender != null) && this.sender.equals(rhs.sender)))) && (this.chainId == rhs.chainId)) && ((this.scriptHash == rhs.scriptHash) || ((this.scriptHash != null) && this.scriptHash.equals(rhs.scriptHash)))) && (this.gasUnitPrice == rhs.gasUnitPrice)) && (this.maxGasAmount == rhs.maxGasAmount)) && ((this.scriptBytes == rhs.scriptBytes) || ((this.scriptBytes != null) && this.scriptBytes.equals(rhs.scriptBytes))));
    }

}
