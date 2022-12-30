package diem.listener;

import com.novi.serde.DeserializationError;
import com.novi.serde.Slice;

public class BcsDeserializer extends BinaryDeserializer {
    public BcsDeserializer(byte[] input) {
        super(input, 500L);
    }

    public Float deserialize_f32() throws DeserializationError {
        throw new DeserializationError("Not implemented: deserialize_f32");
    }

    public Double deserialize_f64() throws DeserializationError {
        throw new DeserializationError("Not implemented: deserialize_f64");
    }

    private int deserialize_uleb128_as_u32() throws DeserializationError {
        long value = 0L;

        for(int shift = 0; shift < 32; shift += 7) {
            byte x = this.getByte();
            byte digit = (byte)(x & 127);
            value |= (long)digit << shift;
            if (value < 0L || value > 2147483647L) {
                throw new DeserializationError("Overflow while parsing uleb128-encoded uint32 value");
            }

            if (digit == x) {
                if (shift > 0 && digit == 0) {
                    throw new DeserializationError("Invalid uleb128 number (unexpected zero digit)");
                }

                return (int)value;
            }
        }

        throw new DeserializationError("Overflow while parsing uleb128-encoded uint32 value");
    }

    public long deserialize_len() throws DeserializationError {
        return (long)this.deserialize_uleb128_as_u32();
    }

    public int deserialize_variant_index() throws DeserializationError {
        return this.deserialize_uleb128_as_u32();
    }

    public void check_that_key_slices_are_increasing(Slice key1, Slice key2) throws DeserializationError {
        if (Slice.compare_bytes(this.input.array(), key1, key2) >= 0) {
            throw new DeserializationError("Error while decoding map: keys are not serialized in the expected order");
        }
    }
}
