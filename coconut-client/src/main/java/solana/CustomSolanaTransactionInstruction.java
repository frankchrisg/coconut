package solana;

import com.paymennt.solanaj.data.AccountMeta;
import com.paymennt.solanaj.data.SolanaPublicKey;
import com.paymennt.solanaj.data.SolanaTransactionInstruction;

import java.util.List;

public class CustomSolanaTransactionInstruction extends SolanaTransactionInstruction {
    private long computeBudget;

    public CustomSolanaTransactionInstruction(final SolanaPublicKey programId, final List<AccountMeta> keys,
                                              final byte[] data) {
        super(programId, keys, data);
    }

    public long getComputeBudget() {
        return computeBudget;
    }

    public void setComputeBudget(long computeBudget) {
        this.computeBudget = computeBudget;
    }
}
