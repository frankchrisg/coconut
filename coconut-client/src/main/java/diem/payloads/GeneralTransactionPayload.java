package diem.payloads;

import com.diem.types.*;
import com.diem.utils.AccountAddressUtils;
import com.novi.serde.Bytes;
import diem.helper.AccountInformation;
import diem.helper.TraitHelpers;
import org.apache.log4j.Logger;
import org.hibernate.cfg.NotYetImplementedException;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class GeneralTransactionPayload implements IDiemWritePayload {

    private static final Logger LOG = Logger.getLogger(GeneralTransactionPayload.class);

    private static final byte[] MODULE_DEFAULT_ADDRESS = new byte[]{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1};

    @Override
    public List<TypeTag> getTy_args() {
        return ty_args;
    }

    public void setTy_args(final List<TypeTag> ty_args) {
        this.ty_args = ty_args;
    }

    @Override
    public List<Bytes> getArgs() {
        return args;
    }

    public void setArgs(final List<Bytes> args) {
        this.args = args;
    }

    @Override
    public String getFunction() {
        return function;
    }

    public void setFunction(final String function) {
        this.function = function;
    }

    @Override
    public String getIdentifier() {
        return identifier;
    }

    public void setIdentifier(final String identifier) {
        this.identifier = identifier;
    }

    @Override
    public String getSignature() {
        return signature;
    }

    public void setSignature(final String signature) {
        this.signature = signature;
    }

    @Override
    public List<String> getSenderAddresses() {
        return senderAddresses;
    }

    @Override
    public void setSenderAddresses(final List<String> senderAddresses) {
        this.senderAddresses = senderAddresses;
    }

    @Override
    public void setReceiverAddresses(final List<String> receiverAddresses) {
        this.receiverAddresses = receiverAddresses;
    }

    public String getValueToRead() {
        return valueToRead;
    }

    public void setValueToRead(final String valueToRead) {
        this.valueToRead = valueToRead;
    }

    private List<TypeTag> ty_args;
    private List<Bytes> args;
    private String function;
    private String identifier;
    private String signature;
    private String valueToRead;
    private String prefix;
    private List<String> senderAddresses;
    private List<String> receiverAddresses;
    private AccountInformation senderAccountInformation;

    public AccountInformation getSenderAccountInformation() {
        return senderAccountInformation;
    }

    public void setSenderAccountInformation(final AccountInformation senderAccountInformation) {
        this.senderAccountInformation = senderAccountInformation;
    }

    public AccountInformation getReceiverAccountInformation() {
        return receiverAccountInformation;
    }

    public void setReceiverAccountInformation(final AccountInformation receiverAccountInformation) {
        this.receiverAccountInformation = receiverAccountInformation;
    }

    private AccountInformation receiverAccountInformation;

    public Map<TypeTag, List<String>> getArgsAsString() {
        return argsAsString;
    }

    public void setArgsAsString(final Map<TypeTag, List<String>> argsAsString) {
        this.argsAsString = argsAsString;
    }

    private Map<TypeTag, List<String>> argsAsString;

    @SafeVarargs
    @Override
    public final <E> void setValues(final E... params) {
        setTy_args((List<TypeTag>) params[0]);
        setArgs((List<Bytes>) params[1]);
        setFunction(String.valueOf(params[2]));
        setIdentifier(String.valueOf(params[3]));
    }

    @SafeVarargs
    @Override
    public final <E> void setValuesWithArgsAsString(final E... params) {
        setTy_args((List<TypeTag>) params[0]);
        setArgsAsString((Map<TypeTag, List<String>>) params[1]);
        setFunction(String.valueOf(params[2]));
        setIdentifier(String.valueOf(params[3]));
    }

    @SafeVarargs
    @Override
    public final <E> E getPayload(final E... params) {
        return (E) this;
    }

    @Override
    public TransactionPayload getTransactionPayload() {
        com.diem.types.ScriptFunction.Builder script_function_builder = new com.diem.types.ScriptFunction.Builder();
        script_function_builder.ty_args = ty_args;
        if (args != null) {
            script_function_builder.args = args;
        } else {
            List<Bytes> args = new ArrayList<>();
            for (final Map.Entry<TypeTag, List<String>> transactionArgumentStringEntry : getArgsAsString().entrySet()) {
                for (final String moduleParam : transactionArgumentStringEntry.getValue()) {
                    if (transactionArgumentStringEntry.getKey() instanceof TypeTag.U64) {
                        args.add(TraitHelpers.encode_u64_argument(Long.valueOf(moduleParam)));
                    } else if (transactionArgumentStringEntry.getKey() instanceof TypeTag.Vector) {
                        args.add(TraitHelpers.encode_u8vector_argument(Bytes.valueOf(moduleParam.getBytes())));
                    } else if (transactionArgumentStringEntry.getKey() instanceof TypeTag.Address) {
                        for (final String receiverAddress : receiverAddresses) {
                            args.add(TraitHelpers.encode_address_argument(AccountAddressUtils.create(receiverAddress)));
                        }
                    } else {
                        throw new NotYetImplementedException("Not yet implemented");
                    }
                }
            }
            script_function_builder.args = args;
        }
        script_function_builder.function = new Identifier(function);
        script_function_builder.module = new ModuleId(AccountAddress.valueOf(MODULE_DEFAULT_ADDRESS),
                new Identifier(identifier));
        com.diem.types.TransactionPayload.ScriptFunction.Builder builder =
                new com.diem.types.TransactionPayload.ScriptFunction.Builder();
        builder.value = script_function_builder.build();
        return builder.build();
    }

    @Override
    public void setEventPrefix(final String prefix) {
        this.prefix = prefix;
    }

    @Override
    public String getEventPrefix() {
        if (prefix == null) {
            LOG.debug("Prefix is null");
            return "";
        }
        return prefix;
    }

    @Override
    public <E> void setValueToRead(final E valueToRead) {
        this.valueToRead = (String) valueToRead;
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
