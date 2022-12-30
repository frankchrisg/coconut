package diem.listener;

import com.novi.serde.*;

import java.math.BigInteger;
import java.nio.BufferUnderflowException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.charset.CharacterCodingException;
import java.nio.charset.CharsetDecoder;
import java.nio.charset.StandardCharsets;

public abstract class BinaryDeserializer implements Deserializer {
    protected ByteBuffer input;
    private long containerDepthBudget;
    static final String INPUT_NOT_LARGE_ENOUGH = "Input is not large enough";

    public BinaryDeserializer(byte[] input, long maxContainerDepth) {
        this.input = ByteBuffer.wrap(input);
        this.input.order(ByteOrder.LITTLE_ENDIAN);
        this.containerDepthBudget = maxContainerDepth;
    }

    public void increase_container_depth() throws DeserializationError {
        if (this.containerDepthBudget == 0L) {
            throw new DeserializationError("Exceeded maximum container depth");
        } else {
            --this.containerDepthBudget;
        }
    }

    public void decrease_container_depth() {
        ++this.containerDepthBudget;
    }

    public String deserialize_str() throws DeserializationError {
        long len = this.deserialize_len();
        if (len >= 0L && len <= 2147483647L) {
            byte[] content = new byte[(int)len];
            this.read(content);

            // only here to handle single digits as digits and not as control characters
            for (int i = 0; i < content.length; i++) {
                if( content[i] >= 0 && content[i] <= 9) {
                    content[i] = String.valueOf(content[i]).getBytes()[0];
                }
            }

            CharsetDecoder decoder = StandardCharsets.UTF_8.newDecoder();

            try {
                decoder.decode(ByteBuffer.wrap(content));
            } catch (CharacterCodingException var6) {
                throw new DeserializationError("Incorrect UTF8 string");
            }

            return new String(content);
        } else {
            throw new DeserializationError("Incorrect length value for Java string");
        }
    }

    public Bytes deserialize_bytes() throws DeserializationError {
        long len = this.deserialize_len();
        if (len >= 0L && len <= 2147483647L) {
            byte[] content = new byte[(int)len];
            this.read(content);
            return new Bytes(content);
        } else {
            throw new DeserializationError("Incorrect length value for Java array");
        }
    }

    public Boolean deserialize_bool() throws DeserializationError {
        byte value = this.getByte();
        if (value == 0) {
            return false;
        } else if (value == 1) {
            return true;
        } else {
            throw new DeserializationError("Incorrect boolean value");
        }
    }

    public Unit deserialize_unit() throws DeserializationError {
        return new Unit();
    }

    public Character deserialize_char() throws DeserializationError {
        throw new DeserializationError("Not implemented: deserialize_char");
    }

    @Unsigned
    public Byte deserialize_u8() throws DeserializationError {
        return this.getByte();
    }

    @Unsigned
    public Short deserialize_u16() throws DeserializationError {
        return this.getShort();
    }

    @Unsigned
    public Integer deserialize_u32() throws DeserializationError {
        return this.getInt();
    }

    @Unsigned
    public Long deserialize_u64() throws DeserializationError {
        return this.getLong();
    }

    @Unsigned
    @Int128
    public BigInteger deserialize_u128() throws DeserializationError {
        BigInteger signed = this.deserialize_i128();
        return signed.compareTo(BigInteger.ZERO) >= 0 ? signed : signed.add(BigInteger.ONE.shiftLeft(128));
    }

    public Byte deserialize_i8() throws DeserializationError {
        return this.getByte();
    }

    public Short deserialize_i16() throws DeserializationError {
        return this.getShort();
    }

    public Integer deserialize_i32() throws DeserializationError {
        return this.getInt();
    }

    public Long deserialize_i64() throws DeserializationError {
        return this.getLong();
    }

    @Int128
    public BigInteger deserialize_i128() throws DeserializationError {
        byte[] content = new byte[16];
        this.read(content);
        byte[] reversed = new byte[16];

        for(int i = 0; i < 16; ++i) {
            reversed[i] = content[15 - i];
        }

        return new BigInteger(reversed);
    }

    public boolean deserialize_option_tag() throws DeserializationError {
        return this.deserialize_bool();
    }

    public int get_buffer_offset() {
        return this.input.position();
    }

    protected byte getByte() throws DeserializationError {
        try {
            return this.input.get();
        } catch (BufferUnderflowException var2) {
            throw new DeserializationError("Input is not large enough");
        }
    }

    protected short getShort() throws DeserializationError {
        try {
            return this.input.getShort();
        } catch (BufferUnderflowException var2) {
            throw new DeserializationError("Input is not large enough");
        }
    }

    protected int getInt() throws DeserializationError {
        try {
            return this.input.getInt();
        } catch (BufferUnderflowException var2) {
            throw new DeserializationError("Input is not large enough");
        }
    }

    protected long getLong() throws DeserializationError {
        try {
            return this.input.getLong();
        } catch (BufferUnderflowException var2) {
            throw new DeserializationError("Input is not large enough");
        }
    }

    protected float getFloat() throws DeserializationError {
        try {
            return this.input.getFloat();
        } catch (BufferUnderflowException var2) {
            throw new DeserializationError("Input is not large enough");
        }
    }

    protected double getDouble() throws DeserializationError {
        try {
            return this.input.getDouble();
        } catch (BufferUnderflowException var2) {
            throw new DeserializationError("Input is not large enough");
        }
    }

    protected void read(byte[] content) throws DeserializationError {
        try {
            this.input.get(content);
        } catch (BufferUnderflowException var3) {
            throw new DeserializationError("Input is not large enough");
        }
    }
}
