package solana.instructions;

import org.near.borshj.Borsh;
import org.near.borshj.BorshReader;
import org.near.borshj.BorshWriter;
import solana.helper.KeyHelper;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.charset.StandardCharsets;
import java.util.List;

public class Instructions {

    public static class DoNothingInstruction implements Borsh {
        public static final int DO_NOTHING_FUNC = 0;
        public int type;
        public String sig;

        public DoNothingInstruction(int type, String sig) {
            this.type = type;
            this.sig = sig;
        }

        public byte[] serialize() {

            ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
            BorshWriter borshWriter = new BorshWriter(byteArrayOutputStream);

            borshWriter.writeU32(type);

            int stringLength = sig.getBytes(StandardCharsets.UTF_8).length;
            borshWriter.writeU32(stringLength);

            borshWriter.write(sig.getBytes(StandardCharsets.UTF_8));

            try {
                byteArrayOutputStream.flush();
                byteArrayOutputStream.close();
            } catch (IOException ex) {
                throw new RuntimeException(ex);
            }
            return byteArrayOutputStream.toByteArray();
        }

        public void deserialize(final InputStream in) {
            BorshReader borshReader = new BorshReader(in);
            type = borshReader.readU32();

            int stringLength = borshReader.readU32();

            byte[] stringBuffer = new byte[stringLength];
            try {
                in.read(stringBuffer);
            } catch (IOException ex) {
                throw new RuntimeException(ex);
            }
            sig = new String(stringBuffer, StandardCharsets.UTF_8);

            System.out.println(type + " " + sig);

        }
    }

    public static class SortInstruction {
        public static final int SORT_FUNC = 0;

        private final int type;
        private final List<Integer> a;
        private final int l;
        private final int r;
        private final String sig;

        public SortInstruction(int type, List<Integer> a, int l, int r, String sig) {
            this.type = type;
            this.a = a;
            this.l = l;
            this.r = r;
            this.sig = sig;
        }

        public static byte[] serializeInstruction(final SortInstruction instruction) {
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            BorshWriter borshWriter = new BorshWriter(outputStream);

            borshWriter.writeU32(instruction.type);
            borshWriter.writeArray(instruction.a);
            borshWriter.writeU32(instruction.l);
            borshWriter.writeU32(instruction.r);

            int stringLength = instruction.sig.getBytes(StandardCharsets.UTF_8).length;
            borshWriter.writeU32(stringLength);

            borshWriter.write(instruction.sig.getBytes(StandardCharsets.UTF_8));

            return outputStream.toByteArray();
        }
    }

    public static class LoopInstruction {
        public static final int LOOP_FUNC = 0;

        private final int type;
        private final int start;
        private final int end;
        private final String sig;

        public LoopInstruction(int type, int l, int r, String sig) {
            this.type = type;
            this.start = l;
            this.end = r;
            this.sig = sig;
        }

        public static byte[] serializeInstruction(final LoopInstruction instruction) {
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            BorshWriter borshWriter = new BorshWriter(outputStream);

            borshWriter.writeU32(instruction.type);
            borshWriter.writeU64(instruction.start);
            borshWriter.writeU64(instruction.end);

            int stringLength = instruction.sig.getBytes(StandardCharsets.UTF_8).length;
            borshWriter.writeU32(stringLength);

            borshWriter.write(instruction.sig.getBytes(StandardCharsets.UTF_8));

            return outputStream.toByteArray();
        }
    }


    public static class MemoryInstruction {
        public static final int MEMORY_FUNC = 0;

        private final int type;
        private final int lenOut;
        private final int lenIn;

        private final int firstChar;

        private final int length;
        private final String sig;

        public MemoryInstruction(int type, int lenOut, int lenIn, int firstChar, int length, String sig) {
            this.type = type;
            this.lenOut = lenOut;
            this.lenIn = lenIn;
            this.firstChar = firstChar;
            this.length = length;
            this.sig = sig;
        }

        public static byte[] serializeInstruction(final MemoryInstruction instruction) {
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            BorshWriter borshWriter = new BorshWriter(outputStream);

            borshWriter.writeU32(instruction.type);

            borshWriter.writeU64(instruction.lenOut);
            borshWriter.writeU64(instruction.lenIn);
            borshWriter.writeU64(instruction.firstChar);
            borshWriter.writeU64(instruction.length);

            int stringLength = instruction.sig.getBytes(StandardCharsets.UTF_8).length;
            borshWriter.writeU32(stringLength);

            borshWriter.write(instruction.sig.getBytes(StandardCharsets.UTF_8));

            return outputStream.toByteArray();
        }
    }

    public static class RecursionInstruction {
        public static final int RECURSION_FUNC = 0;

        private final int type;
        private final int start;
        private final int end;
        private final String sig;

        public RecursionInstruction(int type, int start, int end, String sig) {
            this.type = type;
            this.start = start;
            this.end = end;
            this.sig = sig;
        }

        public static byte[] serializeInstruction(final RecursionInstruction instruction) {
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            BorshWriter borshWriter = new BorshWriter(outputStream);

            borshWriter.writeU32(instruction.type);

            borshWriter.writeU32(instruction.start);
            borshWriter.writeU32(instruction.end);

            int stringLength = instruction.sig.getBytes(StandardCharsets.UTF_8).length;
            borshWriter.writeU32(stringLength);

            borshWriter.write(instruction.sig.getBytes(StandardCharsets.UTF_8));

            return outputStream.toByteArray();
        }
    }

    public static class KeyValueInstruction {

        private final int type;
        private final String key;
        private String value;
        private final String sig;

        public KeyValueInstruction(int type, String key, String sig) {
            this.type = type;
            this.key = key;
            this.sig = sig;
        }

        public KeyValueInstruction(int type, String key, String value, String sig) {
            this.type = type;
            this.key = key;
            this.value = value;
            this.sig = sig;
        }

        public static byte[] serializeInstruction(final KeyValueInstruction instruction) {
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            BorshWriter borshWriter = new BorshWriter(outputStream);

            borshWriter.writeU32(instruction.type);

            int keyLength = instruction.key.getBytes(StandardCharsets.UTF_8).length;
            borshWriter.writeU32(keyLength);
            borshWriter.write(instruction.key.getBytes(StandardCharsets.UTF_8));

            if (instruction.type == 1) { // 1 = set
                int valueLength = instruction.value.getBytes(StandardCharsets.UTF_8).length;
                borshWriter.writeU32(valueLength);
                borshWriter.write(instruction.value.getBytes(StandardCharsets.UTF_8));
            }

            int stringLength = instruction.sig.getBytes(StandardCharsets.UTF_8).length;
            borshWriter.writeU32(stringLength);
            borshWriter.write(instruction.sig.getBytes(StandardCharsets.UTF_8));

            return outputStream.toByteArray();
        }

    }

    public static class IOInstruction {

        private final int type;
        private final int size;
        private final int start_key;
        private int ret_len;
        private final String sig;

        public IOInstruction(int type, int size, int start_key, int ret_len, String sig) {
            this.type = type;
            this.size = size;
            this.start_key = start_key;
            this.ret_len = ret_len;
            this.sig = sig;
        }

        public IOInstruction(int type, int size, int start_key, String sig) {
            this.type = type;
            this.size = size;
            this.start_key = start_key;
            this.sig = sig;
        }

        public static byte[] serializeInstruction(final IOInstruction instruction) {
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            BorshWriter borshWriter = new BorshWriter(outputStream);

            borshWriter.writeU32(instruction.type);

            borshWriter.writeU32(instruction.size);
            borshWriter.writeU32(instruction.start_key);

            if (instruction.type == 0) { // 0 = write
                borshWriter.writeU32(instruction.ret_len);
            }

            int stringLength = instruction.sig.getBytes(StandardCharsets.UTF_8).length;
            borshWriter.writeU32(stringLength);
            borshWriter.write(instruction.sig.getBytes(StandardCharsets.UTF_8));

            return outputStream.toByteArray();
        }

    }

    public static class SBCreateAccountInstruction {

        private final int type;
        private final String acctId;
        private final int checking;
        private final int savings;
        private final String sig;

        public SBCreateAccountInstruction(int type, String acctId, int checking, int savings, String sig) {
            this.type = type;
            this.acctId = acctId;
            this.checking = checking;
            this.savings = savings;
            this.sig = sig;
        }

        public static byte[] serializeInstruction(final SBCreateAccountInstruction instruction) {
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            BorshWriter borshWriter = new BorshWriter(outputStream);

            borshWriter.writeU32(instruction.type);

            int acctIdLength = instruction.acctId.getBytes(StandardCharsets.UTF_8).length;
            borshWriter.writeU32(acctIdLength);
            borshWriter.write(instruction.acctId.getBytes(StandardCharsets.UTF_8));

            borshWriter.writeU32(instruction.checking);
            borshWriter.writeU32(instruction.savings);

            int stringLength = instruction.sig.getBytes(StandardCharsets.UTF_8).length;
            borshWriter.writeU32(stringLength);
            borshWriter.write(instruction.sig.getBytes(StandardCharsets.UTF_8));

            return outputStream.toByteArray();
        }

    }

    public static class SBSendPaymentInstruction {

        private final int type;

        private final KeyHelper.Pubkey sender;

        private final KeyHelper.Pubkey destination;

        private final String acctId0;
        private final String acctId1;

        private final int amount;
        private final String sig;

        public SBSendPaymentInstruction(int type, byte[] sender, byte[] destination, String acctId0, String acctId1,
                                        int amount
                , String sig) {
            this.type = type;
            this.sender = new KeyHelper.Pubkey(sender);
            this.destination = new KeyHelper.Pubkey(destination);
            this.acctId0 = acctId0;
            this.acctId1 = acctId1;
            this.amount = amount;
            this.sig = sig;
        }

        public static byte[] serializeInstruction(final SBSendPaymentInstruction instruction) {
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            BorshWriter borshWriter = new BorshWriter(outputStream);

            borshWriter.writeU32(instruction.type);

            instruction.sender.serialize(borshWriter);
            instruction.destination.serialize(borshWriter);

            int acctIdLength0 = instruction.acctId0.getBytes(StandardCharsets.UTF_8).length;
            borshWriter.writeU32(acctIdLength0);
            borshWriter.write(instruction.acctId0.getBytes(StandardCharsets.UTF_8));

            int acctIdLength1 = instruction.acctId1.getBytes(StandardCharsets.UTF_8).length;
            borshWriter.writeU32(acctIdLength1);
            borshWriter.write(instruction.acctId1.getBytes(StandardCharsets.UTF_8));

            writeI32(borshWriter, instruction.amount);

            int stringLength = instruction.sig.getBytes(StandardCharsets.UTF_8).length;
            borshWriter.writeU32(stringLength);
            borshWriter.write(instruction.sig.getBytes(StandardCharsets.UTF_8));

            return outputStream.toByteArray();
        }

        private static void writeI32(final BorshWriter borshWriter, final int value) {
            byte[] bytes = ByteBuffer.allocate(4).order(ByteOrder.LITTLE_ENDIAN).putInt(value).array();
            borshWriter.write(bytes);
        }

    }

    public static class SBAmalgamateInstruction {

        private final int type;

        private final KeyHelper.Pubkey sender;

        private final KeyHelper.Pubkey destination;
        private final String acctId0;
        private final String acctId1;
        private final String sig;

        public SBAmalgamateInstruction(int type, byte[] sender, byte[] destination, String acctId0, String acctId1,
                                       String sig) {
            this.type = type;
            this.sender = new KeyHelper.Pubkey(sender);
            this.destination = new KeyHelper.Pubkey(destination);
            this.acctId0 = acctId0;
            this.acctId1 = acctId1;
            this.sig = sig;
        }

        public static byte[] serializeInstruction(final SBAmalgamateInstruction instruction) {
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            BorshWriter borshWriter = new BorshWriter(outputStream);

            borshWriter.writeU32(instruction.type);

            instruction.sender.serialize(borshWriter);
            instruction.destination.serialize(borshWriter);

            int acctIdLength0 = instruction.acctId0.getBytes(StandardCharsets.UTF_8).length;
            borshWriter.writeU32(acctIdLength0);
            borshWriter.write(instruction.acctId0.getBytes(StandardCharsets.UTF_8));

            int acctIdLength1 = instruction.acctId1.getBytes(StandardCharsets.UTF_8).length;
            borshWriter.writeU32(acctIdLength1);
            borshWriter.write(instruction.acctId1.getBytes(StandardCharsets.UTF_8));

            int stringLength = instruction.sig.getBytes(StandardCharsets.UTF_8).length;
            borshWriter.writeU32(stringLength);
            borshWriter.write(instruction.sig.getBytes(StandardCharsets.UTF_8));

            return outputStream.toByteArray();
        }

    }

}
