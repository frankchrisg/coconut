package diem.listener;

import client.client.ClientObject;
import client.supplements.ExceptionHandler;
import co.paralleluniverse.fibers.Suspendable;
import com.google.gson.Gson;
import com.novi.serde.DeserializationError;
import diem.configuration.Configuration;
import diem.helper.json.blockData.BlockData;
import diem.helper.json.blockData.Event;
import diem.statistics.BlockStatisticObject;
import net.i2p.crypto.eddsa.Utils;
import okhttp3.*;
import org.apache.log4j.Logger;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Map;
import java.util.Objects;
import java.util.Queue;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ConcurrentHashMap;

public class WebsocketListener {

    private static final Logger LOG = Logger.getLogger(WebsocketListener.class);

    public CompletableFuture<Boolean> getIsSubscribed() {
        return isSubscribed;
    }

    private final CompletableFuture<Boolean> isSubscribed = new CompletableFuture<>();

    private static final Map<String, WebSocket> WEBSOCKET_LISTENERS = new ConcurrentHashMap<>();

    public static Map<String, WebSocket> getWebsocketListeners() {
        return WEBSOCKET_LISTENERS;
    }

    @Suspendable
    public WebSocket createWebsocketListener(final String urlToSubscribeTo, final String clientId,
                                             final long startVersion, final Queue<ClientObject> clientObjectQueue,
                                             final Listener listener) {

        Request request = new Request.Builder().header("Content-Length",
                String.valueOf(Configuration.CONTENT_LENGTH)).url(urlToSubscribeTo).build();

        WebSocketListener webSocketListener = new WebSocketListener() {
            @Override
            @Suspendable
            public void onClosed(@NotNull final WebSocket webSocket, final int code, @NotNull final String reason) {
                super.onClosed(webSocket, code, reason);
                LOG.info("Websocket closed with reason: " + reason + " Code: " + code);
            }

            @Override
            @Suspendable
            public void onClosing(@NotNull final WebSocket webSocket, final int code, @NotNull final String reason) {
                super.onClosing(webSocket, code, reason);
                LOG.info("Websocket closing with reason: " + reason + " Code: " + code);
            }

            @Override
            @Suspendable
            public void onFailure(@NotNull final WebSocket webSocket, @NotNull final Throwable t,
                                  @Nullable final Response response) {
                super.onFailure(webSocket, t, response);
                LOG.info("Websocket failure with reason: " + Objects.requireNonNull(response).message());
            }

            @Override
            @Suspendable
            public void onMessage(@NotNull final WebSocket webSocket, @NotNull final String text) {
                super.onMessage(webSocket, text);

                LOG.trace("Websocket receiving message with text: " + text);
                isSubscribed.complete(true);

                JSONObject jsonObject = new JSONObject(text);
                if (jsonObject.has("result") && jsonObject.getJSONObject("result").has("events")) {
                    if (Configuration.ENABLE_BLOCK_STATISTICS) {
                        BlockData blockData = new Gson().fromJson(text, BlockData.class);
                        if ("blockmetadata".equals(blockData.getResult().getTransaction().getType())) {

                            if("executed".equals(blockData.getResult().getVmStatus().getType())) {
                                for (final Event event : blockData.getResult().getEvents()) {
                                    if("newblock".equals(event.getData().getType())) {
                                        BlockStatisticObject blockStatisticObject = new BlockStatisticObject();
                                        blockStatisticObject.setBlockId(blockData.getResult().getBytes().substring(4, 68)
                                                /*blockData.getResult().getHash()*/);
                                        LOG.trace("BlockID received: " + blockData.getResult().getBytes().substring(4, 68));
                                        blockStatisticObject.setReceivedTime(System.currentTimeMillis());
                                        blockStatisticObject.setClientId(clientId);
                                        blockStatisticObject.setNumberOfTransactions(0);
                                        blockStatisticObject.setNumberOfActions(0);
                                        blockStatisticObject.setBlockNum(blockData.getResult().getVersion());
                                        listener.getiStatistics().add(blockStatisticObject);
                                    }
                                }
                            }

                        }
                    }

                    JSONArray resultArray = jsonObject.getJSONObject("result").getJSONArray("events");

                    if (resultArray != null) {
                        for (final Object result : resultArray) {
                            JSONObject resultJsonObject = new JSONObject(String.valueOf(result));
                            if (resultJsonObject.has("data")) {
                                JSONObject dataJsonObject = new JSONObject(resultJsonObject.get("data").toString());
                                if (dataJsonObject.has("bytes")) {
                                    try {
                                        listener.handleEvent(clientObjectQueue,
                                                new diem.listener.BcsDeserializer(Utils.hexToBytes(dataJsonObject.get(
                                                        "bytes").toString())).deserialize_str());
                                    } catch (DeserializationError ex) {
                                        ExceptionHandler.logException(ex);
                                    }
                                }
                            }
                        }

                    }

                }
            }

            @Override
            @Suspendable
            public void onMessage(@NotNull final WebSocket webSocket, @NotNull final okio.ByteString bytes) {
                super.onMessage(webSocket, bytes);
                LOG.trace("Websocket receiving message with text (byte): " + bytes);
            }

            @Override
            @Suspendable
            public void onOpen(@NotNull final WebSocket webSocket, final @NotNull Response response) {
                super.onOpen(webSocket, response);
                try {
                    LOG.info("Received response: " + response.message());
                    JSONObject jsonObject;
                    jsonObject =
                                /*new JSONObject("{\"id\": \"cid\", \"method\": " +
                                        "\"subscribe_to_events\", \"params\": {\"event_key\":" +
                                        "\"ff00000000000000ffffffffffffffffffffffffffffffff\", " +
                                        "\"event_seq_num\": 0}, \"jsonrpc\": \"2.0\"}");*/

                            new JSONObject("{\"id\": \"" + clientId + "\", \"method\": " +
                                    "\"subscribe_to_transactions\", \"params\": {\"starting_version\": " + startVersion + "," +
                                    "\"include_events\": true}, " +
                                    "\"jsonrpc\": \"2.0\"}");
                    webSocket.send(Objects.requireNonNull(jsonObject).toString());
                } catch (JSONException jsonException) {
                    LOG.error("JSON Error: " + jsonException.getMessage());
                }
            }
        };
        OkHttpClient client = new OkHttpClient.Builder()
                .build();

        WebSocket webSocket = client.newWebSocket(request, webSocketListener);
        WEBSOCKET_LISTENERS.put(clientId, webSocket);

        return webSocket;
    }

}
