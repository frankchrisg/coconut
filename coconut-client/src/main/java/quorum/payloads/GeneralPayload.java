package quorum.payloads;

import org.apache.log4j.Logger;
import org.hibernate.cfg.NotYetImplementedException;
import org.web3j.abi.FunctionEncoder;
import org.web3j.abi.TypeReference;
import org.web3j.abi.datatypes.Function;
import org.web3j.abi.datatypes.Type;

import java.util.ArrayList;
import java.util.List;

public class GeneralPayload implements IQuorumWritePayload {

    private static final Logger LOG = Logger.getLogger(GeneralPayload.class);

    private final List inputList = new ArrayList<>();
    private final List<TypeReference<?>> outputList = new ArrayList<>();

    private String signature;
    private String function;
    private String valueToRead;
    private String prefix;

    public String getSignature() {
        return signature;
    }

    public void setSignature(final String signature) {
        this.signature = signature;
    }

    @Override
    public <E> E getValueToRead() {
        return (E) valueToRead;
    }

    @Override
    public <E> void setValueToRead(final E valueToRead) {
        this.valueToRead = (String) valueToRead;
    }

    @SafeVarargs
    @Override
    public final <E> E getPayloadAsString(final E... params) {
        return (E) FunctionEncoder.encode(getPayload());
    }

    @SafeVarargs
    @Override
    public final <E> E getPayload(final E... params) {

        Function function = new Function(
                getFunction(),
                getInputList(),
                getOutputList());

        return (E) function;
    }

    public String getFunction() {
        return function;
    }

    public void setFunction(final String function) {
        this.function = function;
    }

    public List getInputList() {
        return inputList;
    }

    public List<TypeReference<?>> getOutputList() {
        return outputList;
    }

    @SafeVarargs
    @Override
    public final <E> void setValues(final E... params) {
        if (params.length == 3) {
            function = (String) params[0];
            List<Type<?>> inputs = (List<Type<?>>) params[1];
            List<TypeReference<?>> outputs = (List<TypeReference<?>>) params[2];
            updateInputList(inputs);
            updateOutputList(outputs);
        } else {
            throw new NotYetImplementedException("Not yet implemented, extend as needed");
        }
    }

    public void updateInputList(final List<Type<?>> inputListParam) {
        inputList.addAll(inputListParam);
    }

    public void updateOutputList(final List<TypeReference<?>> outputListParam) {
        outputList.addAll(outputListParam);
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
    public void setEventPrefix(final String prefix) {
        this.prefix = prefix;
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
