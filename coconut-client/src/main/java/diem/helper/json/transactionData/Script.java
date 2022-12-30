package diem.helper.json.transactionData;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

import javax.annotation.Generated;
import java.util.List;

@Generated("jsonschema2pojo")
public class Script {

    @SerializedName("type")
    @Expose
    private String type;
    @SerializedName("arguments_bcs")
    @Expose
    private List<String> argumentsBcs = null;
    @SerializedName("type_arguments")
    @Expose
    private List<Object> typeArguments = null;
    @SerializedName("module_address")
    @Expose
    private String moduleAddress;
    @SerializedName("module_name")
    @Expose
    private String moduleName;
    @SerializedName("function_name")
    @Expose
    private String functionName;

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public List<String> getArgumentsBcs() {
        return argumentsBcs;
    }

    public void setArgumentsBcs(List<String> argumentsBcs) {
        this.argumentsBcs = argumentsBcs;
    }

    public List<Object> getTypeArguments() {
        return typeArguments;
    }

    public void setTypeArguments(List<Object> typeArguments) {
        this.typeArguments = typeArguments;
    }

    public String getModuleAddress() {
        return moduleAddress;
    }

    public void setModuleAddress(String moduleAddress) {
        this.moduleAddress = moduleAddress;
    }

    public String getModuleName() {
        return moduleName;
    }

    public void setModuleName(String moduleName) {
        this.moduleName = moduleName;
    }

    public String getFunctionName() {
        return functionName;
    }

    public void setFunctionName(String functionName) {
        this.functionName = functionName;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(Script.class.getName()).append('@').append(Integer.toHexString(System.identityHashCode(this))).append('[');
        sb.append("type");
        sb.append('=');
        sb.append(((this.type == null) ? "<null>" : this.type));
        sb.append(',');
        sb.append("argumentsBcs");
        sb.append('=');
        sb.append(((this.argumentsBcs == null) ? "<null>" : this.argumentsBcs));
        sb.append(',');
        sb.append("typeArguments");
        sb.append('=');
        sb.append(((this.typeArguments == null) ? "<null>" : this.typeArguments));
        sb.append(',');
        sb.append("moduleAddress");
        sb.append('=');
        sb.append(((this.moduleAddress == null) ? "<null>" : this.moduleAddress));
        sb.append(',');
        sb.append("moduleName");
        sb.append('=');
        sb.append(((this.moduleName == null) ? "<null>" : this.moduleName));
        sb.append(',');
        sb.append("functionName");
        sb.append('=');
        sb.append(((this.functionName == null) ? "<null>" : this.functionName));
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
        result = ((result * 31) + ((this.argumentsBcs == null) ? 0 : this.argumentsBcs.hashCode()));
        result = ((result * 31) + ((this.moduleAddress == null) ? 0 : this.moduleAddress.hashCode()));
        result = ((result * 31) + ((this.functionName == null) ? 0 : this.functionName.hashCode()));
        result = ((result * 31) + ((this.moduleName == null) ? 0 : this.moduleName.hashCode()));
        result = ((result * 31) + ((this.type == null) ? 0 : this.type.hashCode()));
        return result;
    }

    @Override
    public boolean equals(Object other) {
        if (other == this) {
            return true;
        }
        if ((other instanceof Script) == false) {
            return false;
        }
        Script rhs = ((Script) other);
        return (((((((this.typeArguments == rhs.typeArguments) || ((this.typeArguments != null) && this.typeArguments.equals(rhs.typeArguments))) && ((this.argumentsBcs == rhs.argumentsBcs) || ((this.argumentsBcs != null) && this.argumentsBcs.equals(rhs.argumentsBcs)))) && ((this.moduleAddress == rhs.moduleAddress) || ((this.moduleAddress != null) && this.moduleAddress.equals(rhs.moduleAddress)))) && ((this.functionName == rhs.functionName) || ((this.functionName != null) && this.functionName.equals(rhs.functionName)))) && ((this.moduleName == rhs.moduleName) || ((this.moduleName != null) && this.moduleName.equals(rhs.moduleName)))) && ((this.type == rhs.type) || ((this.type != null) && this.type.equals(rhs.type))));
    }

}
