package diem.payloads;

import diem.helper.AccountInformation;

import java.util.List;

public interface IDiemWritePayload extends IDiemPayload {

    Payload_Type PAYLOAD_TYPE = Payload_Type.WRITE;

    <E> E getTy_args();

    <E> E getArgs();

    <E> E getFunction();

    <E> E getIdentifier();

    <E> void setValuesWithArgsAsString(E... params);

    <E> E getTransactionPayload();

    <E> E getSenderAccountInformation();

    void setSenderAccountInformation(AccountInformation senderAccountInformation);

    <E> E getReceiverAccountInformation();

    void setReceiverAccountInformation(AccountInformation receiverAccountInformation);

    <E> E getSignature();

    void setSignature(String signature);

    void setSenderAddresses(List<String> senderAddresses);

    List<String> getSenderAddresses();

    void setReceiverAddresses(List<String> receiverAddresses);

    <E> E getValueToRead();

    <E> void setValueToRead(E valueToRead);

    String getEventPrefix();

    void setEventPrefix(String prefix);

}
