package solana;

import com.paymennt.solanaj.api.rpc.SolanaRpcClient;
import com.paymennt.solanaj.api.rpc.types.AccountInfo;
import com.paymennt.solanaj.data.SolanaAccount;
import com.paymennt.solanaj.data.SolanaPublicKey;
import com.paymennt.solanaj.data.SolanaTransaction;
import com.paymennt.solanaj.data.SolanaTransactionInstruction;
import com.paymennt.solanaj.program.SystemProgram;

import java.util.Arrays;
import java.util.Collections;

public class CreateAccount {

    public static void createAccount(final SolanaPublicKey userAccountPublicKey, final SolanaRpcClient client,
                                     final SolanaPublicKey programId,
                                     final SolanaAccount userAccount, final int space) {
        SolanaAccount solanaAccount = new SolanaAccount();
        SolanaPublicKey solanaPublicKey = solanaAccount.getPublicKey();

        long minBalanceForRentExemption = client.getApi().getMinimumBalanceForRentExemption(space);

        SolanaTransactionInstruction transferInstruction = SystemProgram.transfer(
                userAccountPublicKey,
                solanaPublicKey,
                minBalanceForRentExemption
        );
        SolanaTransaction transferTransaction = new SolanaTransaction();
        transferTransaction.addInstruction(transferInstruction);
        transferTransaction.setFeePayer(userAccountPublicKey);
        transferTransaction.setRecentBlockHash(client.getApi().getRecentBlockhash());
        transferTransaction.sign(Collections.singletonList(userAccount));
        String txidTransfer = client.getApi().sendTransaction(transferTransaction);

        SolanaTransactionInstruction createAccountTransactionInstruction = SystemProgram.createAccount(
                userAccountPublicKey,
                solanaPublicKey,
                minBalanceForRentExemption,
                space,
                programId
        );
        SolanaTransaction createAccountTransaction = new SolanaTransaction();
        createAccountTransaction.addInstruction(createAccountTransactionInstruction);
        createAccountTransaction.setFeePayer(userAccountPublicKey);
        createAccountTransaction.setRecentBlockHash(client.getApi().getRecentBlockhash());
        createAccountTransaction.sign(Arrays.asList(userAccount, solanaAccount));
        String txidCreateAccount = client.getApi().sendTransaction(createAccountTransaction);

        System.out.println("Transfer-TXID: " + txidTransfer + " Create-TXID: " + txidCreateAccount);

        AccountInfo accountData = client.getApi().getAccountInfo(solanaPublicKey.toBase58());
        System.out.println("Owner: " + accountData.getValue().getOwner());
        System.out.println("Data: " + accountData.getValue().getData());

    }

}
