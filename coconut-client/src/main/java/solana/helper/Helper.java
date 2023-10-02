package solana.helper;

public class Helper {

    public static String byteToUnsignedHex(final int i) {
        StringBuilder hex = new StringBuilder(Integer.toHexString(i));
        while (hex.length() < 8) {
            hex.insert(0, "0");
        }
        return hex.toString();
    }

    public static String intArrToHex(final int[] arr) {
        StringBuilder builder = new StringBuilder(arr.length * 8);
        for (final int b : arr) {
            builder.append(byteToUnsignedHex(b));
        }
        return builder.toString();
    }

}
