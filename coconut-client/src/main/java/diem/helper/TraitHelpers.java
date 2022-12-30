package diem.helper;

import co.paralleluniverse.fibers.Suspendable;
import com.diem.types.*;
import com.novi.bcs.BcsSerializer;
import com.novi.serde.Bytes;
import com.novi.serde.Deserializer;
import com.novi.serde.SerializationError;
import com.novi.serde.Unsigned;

import java.math.BigInteger;
import java.util.List;

public final class TraitHelpers {

    private TraitHelpers() {
    }

    @Suspendable
    public static void serialize_array16_u8_array(final java.util.@com.novi.serde.ArrayLen(length = 16) List<@com.novi.serde.Unsigned Byte> value, final com.novi.serde.Serializer serializer) throws com.novi.serde.SerializationError {
        if (value.size() != 16) {
            throw new java.lang.IllegalArgumentException("Invalid length for fixed-size array: " + value.size() + " " + "instead of " + 16);
        }
        for (final @com.novi.serde.Unsigned Byte item : value) {
            serializer.serialize_u8(item);
        }
    }

    @Suspendable
    public static java.util.@com.novi.serde.ArrayLen(length = 16) List<@com.novi.serde.Unsigned Byte> deserialize_array16_u8_array(final com.novi.serde.Deserializer deserializer) throws com.novi.serde.DeserializationError {
        java.util.List<@com.novi.serde.Unsigned Byte> obj = new java.util.ArrayList<@com.novi.serde.Unsigned Byte>(16);
        for (long i = 0; i < 16; i++) {
            obj.add(deserializer.deserialize_u8());
        }
        return obj;
    }

    @Suspendable
    public static void serialize_option_bytes(final java.util.Optional<com.novi.serde.Bytes> value,
                                              final com.novi.serde.Serializer serializer) throws com.novi.serde.SerializationError {
        if (value.isPresent()) {
            serializer.serialize_option_tag(true);
            serializer.serialize_bytes(value.get());
        } else {
            serializer.serialize_option_tag(false);
        }
    }

    @Suspendable
    public static java.util.Optional<com.novi.serde.Bytes> deserialize_option_bytes(final com.novi.serde.Deserializer deserializer) throws com.novi.serde.DeserializationError {
        boolean tag = deserializer.deserialize_option_tag();
        if (!tag) {
            return java.util.Optional.empty();
        } else {
            return java.util.Optional.of(deserializer.deserialize_bytes());
        }
    }

    @Suspendable
    public static void serialize_option_str(final java.util.Optional<String> value,
                                            final com.novi.serde.Serializer serializer) throws com.novi.serde.SerializationError {
        if (value.isPresent()) {
            serializer.serialize_option_tag(true);
            serializer.serialize_str(value.get());
        } else {
            serializer.serialize_option_tag(false);
        }
    }

    @Suspendable
    public static java.util.Optional<String> deserialize_option_str(final com.novi.serde.Deserializer deserializer) throws com.novi.serde.DeserializationError {
        boolean tag = deserializer.deserialize_option_tag();
        if (!tag) {
            return java.util.Optional.empty();
        } else {
            return java.util.Optional.of(deserializer.deserialize_str());
        }
    }

    @Suspendable
    public static void serialize_option_u64(final java.util.Optional<@com.novi.serde.Unsigned Long> value,
                                            final com.novi.serde.Serializer serializer) throws com.novi.serde.SerializationError {
        if (value.isPresent()) {
            serializer.serialize_option_tag(true);
            serializer.serialize_u64(value.get());
        } else {
            serializer.serialize_option_tag(false);
        }
    }

    @Suspendable
    public static java.util.Optional<@com.novi.serde.Unsigned Long> deserialize_option_u64(final com.novi.serde.Deserializer deserializer) throws com.novi.serde.DeserializationError {
        boolean tag = deserializer.deserialize_option_tag();
        if (!tag) {
            return java.util.Optional.empty();
        } else {
            return java.util.Optional.of(deserializer.deserialize_u64());
        }
    }

    @Suspendable
    public static void serialize_tuple2_AccessPath_WriteOp(final com.novi.serde.Tuple2<AccessPath, WriteOp> value,
                                                           final com.novi.serde.Serializer serializer) throws com.novi.serde.SerializationError {
        value.field0.serialize(serializer);
        value.field1.serialize(serializer);
    }

    @Suspendable
    public static com.novi.serde.Tuple2<AccessPath, WriteOp> deserialize_tuple2_AccessPath_WriteOp(final com.novi.serde.Deserializer deserializer) throws com.novi.serde.DeserializationError {
        return new com.novi.serde.Tuple2<>(AccessPath.deserialize(deserializer), WriteOp.deserialize(deserializer));
    }

    @Suspendable
    public static void serialize_vector_AccountAddress(final java.util.List<AccountAddress> value,
                                                       final com.novi.serde.Serializer serializer) throws com.novi.serde.SerializationError {
        serializer.serialize_len(value.size());
        for (final AccountAddress item : value) {
            item.serialize(serializer);
        }
    }

    @Suspendable
    public static java.util.List<AccountAddress> deserialize_vector_AccountAddress(final com.novi.serde.Deserializer deserializer) throws com.novi.serde.DeserializationError {
        long length = deserializer.deserialize_len();
        java.util.List<AccountAddress> obj = new java.util.ArrayList<>((int) length);
        for (long i = 0; i < length; i++) {
            obj.add(AccountAddress.deserialize(deserializer));
        }
        return obj;
    }

    @Suspendable
    public static void serialize_vector_ContractEvent(final java.util.List<ContractEvent> value,
                                                      final com.novi.serde.Serializer serializer) throws com.novi.serde.SerializationError {
        serializer.serialize_len(value.size());
        for (final ContractEvent item : value) {
            item.serialize(serializer);
        }
    }

    @Suspendable
    public static java.util.List<ContractEvent> deserialize_vector_ContractEvent(final com.novi.serde.Deserializer deserializer) throws com.novi.serde.DeserializationError {
        long length = deserializer.deserialize_len();
        java.util.List<ContractEvent> obj = new java.util.ArrayList<>((int) length);
        for (long i = 0; i < length; i++) {
            obj.add(ContractEvent.deserialize(deserializer));
        }
        return obj;
    }

    @Suspendable
    public static void serialize_vector_TransactionArgument(final java.util.List<TransactionArgument> value,
                                                            final com.novi.serde.Serializer serializer) throws com.novi.serde.SerializationError {
        serializer.serialize_len(value.size());
        for (final TransactionArgument item : value) {
            item.serialize(serializer);
        }
    }

    @Suspendable
    public static java.util.List<TransactionArgument> deserialize_vector_TransactionArgument(final com.novi.serde.Deserializer deserializer) throws com.novi.serde.DeserializationError {
        long length = deserializer.deserialize_len();
        java.util.List<TransactionArgument> obj = new java.util.ArrayList<>((int) length);
        for (long i = 0; i < length; i++) {
            obj.add(TransactionArgument.deserialize(deserializer));
        }
        return obj;
    }

    @Suspendable
    public static void serialize_vector_TypeTag(final java.util.List<TypeTag> value,
                                                final com.novi.serde.Serializer serializer) throws com.novi.serde.SerializationError {
        serializer.serialize_len(value.size());
        for (final TypeTag item : value) {
            item.serialize(serializer);
        }
    }

    @Suspendable
    public static java.util.List<TypeTag> deserialize_vector_TypeTag(final com.novi.serde.Deserializer deserializer) throws com.novi.serde.DeserializationError {
        long length = deserializer.deserialize_len();
        java.util.List<TypeTag> obj = new java.util.ArrayList<>((int) length);
        for (long i = 0; i < length; i++) {
            obj.add(TypeTag.deserialize(deserializer));
        }
        return obj;
    }

    @Suspendable
    public static void serialize_vector_bytes(final java.util.List<com.novi.serde.Bytes> value,
                                              final com.novi.serde.Serializer serializer) throws com.novi.serde.SerializationError {
        serializer.serialize_len(value.size());
        for (final com.novi.serde.Bytes item : value) {
            serializer.serialize_bytes(item);
        }
    }

    @Suspendable
    public static java.util.List<com.novi.serde.Bytes> deserialize_vector_bytes(final com.novi.serde.Deserializer deserializer) throws com.novi.serde.DeserializationError {
        long length = deserializer.deserialize_len();
        java.util.List<com.novi.serde.Bytes> obj = new java.util.ArrayList<>((int) length);
        for (long i = 0; i < length; i++) {
            obj.add(deserializer.deserialize_bytes());
        }
        return obj;
    }

    @Suspendable
    public static void serialize_vector_str(final java.util.List<String> value,
                                            final com.novi.serde.Serializer serializer) throws com.novi.serde.SerializationError {
        serializer.serialize_len(value.size());
        for (final String item : value) {
            serializer.serialize_str(item);
        }
    }

    @Suspendable
    public static java.util.List<String> deserialize_vector_str(final com.novi.serde.Deserializer deserializer) throws com.novi.serde.DeserializationError {
        long length = deserializer.deserialize_len();
        java.util.List<String> obj = new java.util.ArrayList<>((int) length);
        for (long i = 0; i < length; i++) {
            obj.add(deserializer.deserialize_str());
        }
        return obj;
    }

    @Suspendable
    public static List<List<String>> deserialize_vector_str_list(final Deserializer deserializer) throws com.novi.serde.DeserializationError {
        long length = deserializer.deserialize_len();
        java.util.List<List<String>> obj = new java.util.ArrayList<>();
        for (long i = 0; i < length; i++) {
            obj.add(deserialize_vector_str(deserializer));
        }
        return obj;
    }

    @Suspendable
    public static List<BigInteger> deserialize_vector_bigint(final Deserializer deserializer) throws com.novi.serde.DeserializationError {
        long length = deserializer.deserialize_len();
        java.util.List<BigInteger> obj = new java.util.ArrayList<>((int) length);
        for (long i = 0; i < length; i++) {
            obj.add(deserializer.deserialize_u128());
        }
        return obj;
    }

    @Suspendable
    public static void serialize_vector_tuple2_AccessPath_WriteOp(final java.util.List<com.novi.serde.Tuple2<AccessPath, WriteOp>> value, final com.novi.serde.Serializer serializer) throws com.novi.serde.SerializationError {
        serializer.serialize_len(value.size());
        for (final com.novi.serde.Tuple2<AccessPath, WriteOp> item : value) {
            TraitHelpers.serialize_tuple2_AccessPath_WriteOp(item, serializer);
        }
    }

    @Suspendable
    public static java.util.List<com.novi.serde.Tuple2<AccessPath, WriteOp>> deserialize_vector_tuple2_AccessPath_WriteOp(final com.novi.serde.Deserializer deserializer) throws com.novi.serde.DeserializationError {
        long length = deserializer.deserialize_len();
        java.util.List<com.novi.serde.Tuple2<AccessPath, WriteOp>> obj = new java.util.ArrayList<>((int) length);
        for (long i = 0; i < length; i++) {
            obj.add(TraitHelpers.deserialize_tuple2_AccessPath_WriteOp(deserializer));
        }
        return obj;
    }

    @Suspendable
    public static Bytes encode_bool_argument(final Boolean arg) {
        try {
            BcsSerializer s = new BcsSerializer();
            s.serialize_bool(arg);
            return Bytes.valueOf(s.get_bytes());
        } catch (SerializationError var2) {
            throw new IllegalArgumentException("Unable to serialize argument of type bool");
        }
    }

    @Suspendable
    public static Bytes encode_u64_argument(final @Unsigned Long arg) {
        try {
            BcsSerializer s = new BcsSerializer();
            s.serialize_u64(arg);
            return Bytes.valueOf(s.get_bytes());
        } catch (SerializationError var2) {
            throw new IllegalArgumentException("Unable to serialize argument of type u64");
        }
    }

    @Suspendable
    public static Bytes encode_address_argument(final AccountAddress arg) {
        try {
            return Bytes.valueOf(arg.bcsSerialize());
        } catch (SerializationError var2) {
            throw new IllegalArgumentException("Unable to serialize argument of type address");
        }
    }

    @Suspendable
    public static Bytes encode_u8vector_argument(final Bytes arg) {
        try {
            BcsSerializer s = new BcsSerializer();
            s.serialize_bytes(arg);
            return Bytes.valueOf(s.get_bytes());
        } catch (SerializationError var2) {
            throw new IllegalArgumentException("Unable to serialize argument of type u8vector");
        }
    }

}
