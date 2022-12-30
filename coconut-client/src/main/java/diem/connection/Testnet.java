package diem.connection;

// Copyright (c) The Diem Core Contributors
// SPDX-License-Identifier: Apache-2.0

import co.paralleluniverse.fibers.Suspendable;
import com.diem.DiemClient;
import com.diem.jsonrpc.InvalidResponseException;
import com.diem.jsonrpc.Retry;
import com.diem.types.SignedTransaction;
import com.diem.types.TypeTag;
import com.diem.utils.CurrencyCode;
import com.diem.utils.Hex;
import com.novi.bcs.BcsDeserializer;
import diem.configuration.Configuration;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.utils.URIBuilder;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.apache.log4j.Logger;

import java.net.URI;
import java.util.ArrayList;
import java.util.List;

/**
 * Testnet is utility class for handing Testnet specific data and functions.
 */
public class Testnet {

    private Testnet() {
    }

    private static final Logger LOG = Logger.getLogger(Testnet.class);

    public static final TypeTag XUS_TYPE = CurrencyCode.typeTag(Configuration.DEFAULT_CURRENCY_CODE);
    private static final int DEFAULT_TIMEOUT = Configuration.DEFAULT_TX_TIMEOUT_FAUCET; //10 * 1000;

    /**
     * Mint coins for given authentication key derived account address.
     *
     * @param client       a client connects to Testnet
     * @param amount       amount of coins to mint
     * @param authKey      authentication key of the account, if account does not exist onchain, a new onchain
     *                     account will be created.
     * @param currencyCode currency code of the minted coins
     */
    @Suspendable
    public static void mintCoins(final DiemClient client, final long amount, final String authKey,
                                 final String currencyCode) {
        Retry<Integer> retry = new Retry<>(/*10, 500L*/Configuration.MAX_RETRIES_FAUCET,
                Configuration.WAIT_DURATION_MILLIS_FAUCET, Exception.class);
        try {
            retry.execute(() -> {
                List<SignedTransaction> txns = mintCoinsAsync(amount, authKey.toLowerCase(), currencyCode);
                for (final SignedTransaction txn : txns) {
                    client.waitForTransaction(txn, DEFAULT_TIMEOUT);
                }
                LOG.debug("Minted account with auth key " + authKey);
                return 0;
            });
        } catch (Exception e) {
            throw new RuntimeException("Mint coins failed", e);
        }
    }

    /**
     * This function calls to Faucet service for minting coins, but won't wait for the minting transactions executed.
     * Caller should handle waiting for returned transactions executed successfully and retry if any of the
     * transactions failed.
     *
     * @param amount       amount to mint.
     * @param authKey      authentication key of the account receives minted coins.
     * @param currencyCode currency code of the minted coins.
     * @return List of SignedTransaction submitted by Faucet service for minting the coins
     * @throws Exception retry if exception is thrown.
     */
    @Suspendable
    public static List<SignedTransaction> mintCoinsAsync(final long amount, final String authKey,
                                                         final String currencyCode) throws Exception {
        URIBuilder builder = new URIBuilder(Configuration.FAUCET_SERVER_LIST);
        builder.setParameter("amount", String.valueOf(amount)).setParameter("auth_key", authKey)
                .setParameter("currency_code", currencyCode).setParameter("return_txns", "true");
        URI build = builder.build();

        HttpPost post = new HttpPost(build);
        //post.setHeader("Content-type", "application/json");
        CloseableHttpClient httpClient = HttpClients.createDefault();
        CloseableHttpResponse response = httpClient.execute(post);
        String body = EntityUtils.toString(response.getEntity());
        if (response.getStatusLine().getStatusCode() != 200) {
            throw new InvalidResponseException(response.getStatusLine().getStatusCode(), body);
        }
        BcsDeserializer de = new BcsDeserializer(Hex.decode(body));
        long length = de.deserialize_len();
        List<SignedTransaction> txns = new ArrayList<>();
        for (int i = 0; i < length; i++) {
            txns.add(SignedTransaction.deserialize(de));
        }
        return txns;
    }
}
