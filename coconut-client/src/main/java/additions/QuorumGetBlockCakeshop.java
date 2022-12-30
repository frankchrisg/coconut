package additions;

import okhttp3.*;

import java.io.IOException;
import java.util.Objects;

public class QuorumGetBlockCakeshop {

    private static final String BASE_URL = "http://192.168.122.99:10000/api/block/get";

    private static final MediaType JSON
            = MediaType.parse("application/json; charset=utf-8");

    public static void main(final String... args) {

        OkHttpClient client = new OkHttpClient.Builder()
                .build();

        for (int i = 0; i < 1000; i++) {

            String json = "{\"number\":" + i + "}";

            RequestBody body = RequestBody.create(json, JSON);

            Request request = new Request.Builder()
                    .url(BASE_URL)
                    .post(body)
                    .build();

            Call call = client.newCall(request);
            Response response;
            try {
                response = call.execute();
                System.out.println(Objects.requireNonNull(response.body()).string());
            } catch (IOException ex) {
                ex.printStackTrace();
            }
        }

    }
}
