package diem.payload_patterns;

import co.paralleluniverse.fibers.Suspendable;
import com.diem.stdlib.Helpers;
import com.diem.types.AccountAddress;
import com.diem.types.TransactionPayload;
import com.diem.utils.CurrencyCode;
import com.novi.serde.Bytes;

public class PreparedPayloadScripts {

    private PreparedPayloadScripts() {
    }

    @Suspendable
    public static TransactionPayload.Script getCreateParentVaspAccountPayload(final String currencyCode,
                                                                              final long slidingNonce,
                                                                              final AccountAddress accountAddress,
                                                                              final Bytes authKeyPrefix,
                                                                              final String humanName,
                                                                              final boolean addAllCurrencies) {
        return new TransactionPayload.Script(Helpers.encode_create_parent_vasp_account_script(
                CurrencyCode.typeTag(currencyCode),
                slidingNonce,
                accountAddress,
                authKeyPrefix,
                Bytes.valueOf(humanName.getBytes()),
                addAllCurrencies
        ));
    }

    @Suspendable
    public static TransactionPayload.Script getPeerToPeerWithMetadataPayload(final String currencyCode,
                                                                             final AccountAddress accountAddress,
                                                                             final long amount,
                                                                             final byte[] metadata,
                                                                             final byte[] metadataSignature) {
        return new TransactionPayload.Script(
                Helpers.encode_peer_to_peer_with_metadata_script(
                        CurrencyCode.typeTag(currencyCode),
                        accountAddress,
                        amount,
                        new Bytes(metadata),
                        new Bytes(metadataSignature)));
    }

}
