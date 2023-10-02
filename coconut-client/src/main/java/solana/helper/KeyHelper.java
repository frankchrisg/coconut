package solana.helper;

import org.near.borshj.BorshWriter;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

public class KeyHelper {

    public static byte[] readSecretKeyFromFile(final String keyFile) {
        Path path = Paths.get(keyFile);
        String content;
        try {
            content = Files.readString(path);
        } catch (IOException ex) {
            throw new RuntimeException(ex);
        }
        String[] byteValues = content.replaceAll("\\[", "").replaceAll("]", "").split(",");
        byte[] secretKey = new byte[byteValues.length];

        for (int i = 0; i < byteValues.length; i++) {
            int intValue = Integer.parseInt(byteValues[i].trim());
            secretKey[i] = (byte) (intValue & 0xFF);
        }
        return secretKey;
    }

    public static class Pubkey {
        public byte[] key;

        public Pubkey(byte[] key) {
            this.key = key;
        }

        public void serialize(final BorshWriter writer) {

            int[] unsignedBytes = new int[key.length];
            for (int i = 0; i < key.length; i++) {
                unsignedBytes[i] = key[i] & 0xFF;
            }

            byte[] ba = new byte[unsignedBytes.length];
            for (int i = 0; i < unsignedBytes.length; i++) {
                ba[i] = (byte) (unsignedBytes[i] & 0xFF);
            }

            writer.writeFixedArray(ba);

        }
    }

}
