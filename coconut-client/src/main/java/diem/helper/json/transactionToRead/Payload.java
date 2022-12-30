package diem.helper.json.transactionToRead;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import javax.annotation.Generated;
import java.util.List;

@Generated("jsonschema2pojo")
public class Payload {

    @SerializedName("type")
    @Expose
    private String type;
    @SerializedName("function")
    @Expose
    private String function;
    @SerializedName("type_arguments")
    @Expose
    private List<Object> typeArguments = null;
    @SerializedName("arguments")
    @Expose
    private List<String> arguments = null;

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getFunction() {
        return function;
    }

    public void setFunction(String function) {
        this.function = function;
    }

    public List<Object> getTypeArguments() {
        return typeArguments;
    }

    public void setTypeArguments(List<Object> typeArguments) {
        this.typeArguments = typeArguments;
    }

    public List<String> getArguments() {
        return arguments;
    }

    public void setArguments(List<String> arguments) {
        this.arguments = arguments;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(Payload.class.getName()).append('@').append(Integer.toHexString(System.identityHashCode(this))).append('[');
        sb.append("type");
        sb.append('=');
        sb.append(((this.type == null) ? "<null>" : this.type));
        sb.append(',');
        sb.append("function");
        sb.append('=');
        sb.append(((this.function == null) ? "<null>" : this.function));
        sb.append(',');
        sb.append("typeArguments");
        sb.append('=');
        sb.append(((this.typeArguments == null) ? "<null>" : this.typeArguments));
        sb.append(',');
        sb.append("arguments");
        sb.append('=');
        sb.append(((this.arguments == null) ? "<null>" : this.arguments));
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
        result = ((result * 31) + ((this.typeArguments == null) ? 0 : this.typeArguments.hashCode()));
        result = ((result * 31) + ((this.arguments == null) ? 0 : this.arguments.hashCode()));
        result = ((result * 31) + ((this.type == null) ? 0 : this.type.hashCode()));
        result = ((result * 31) + ((this.function == null) ? 0 : this.function.hashCode()));
        return result;
    }

    @Override
    public boolean equals(Object other) {
        if (other == this) {
            return true;
        }
        if ((other instanceof Payload) == false) {
            return false;
        }
        Payload rhs = ((Payload) other);
        return (((((this.typeArguments == rhs.typeArguments) || ((this.typeArguments != null) && this.typeArguments.equals(rhs.typeArguments))) && ((this.arguments == rhs.arguments) || ((this.arguments != null) && this.arguments.equals(rhs.arguments)))) && ((this.type == rhs.type) || ((this.type != null) && this.type.equals(rhs.type)))) && ((this.function == rhs.function) || ((this.function != null) && this.function.equals(rhs.function))));
    }

}
