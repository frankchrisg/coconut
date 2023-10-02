package solana;

import com.paymennt.solanaj.api.rpc.Cluster;
import com.paymennt.solanaj.api.rpc.SolanaRpcClient;
import com.paymennt.solanaj.api.rpc.types.SolanaCommitment;
import com.paymennt.solanaj.api.ws.SolanaWebSocketClient;
import com.paymennt.solanaj.data.*;
import org.jetbrains.annotations.NotNull;
import solana.instructions.Instructions;
import solana.helper.KeyHelper;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Base64;
import java.util.Random;

public class ExampleClient {

    private static final String PROGRAM_ID = "D4vJnDbfoBtGku3Uo1vPYAkcJ3CnKYN9GYoZQ37y4RRX";
    private static final String RPC_URL = "http://192.168.178.124:20001";

    public static void main(final String[] args) {

        Cluster custom = Cluster.createCluster("CUSTOM", RPC_URL);

        SolanaRpcClient client = new SolanaRpcClient(custom);

        SolanaPublicKey programId = new SolanaPublicKey(PROGRAM_ID);

        SolanaAccount accountWithoutAssociation = SolanaAccount.fromSecret(KeyHelper.readSecretKeyFromFile("E" +
                ":\\ABPES_concurrent\\accountWithoutAssociation.json"));

        SolanaAccount userAccountOne = SolanaAccount.fromSecret(KeyHelper.readSecretKeyFromFile("E:\\ABPES_concurrent" +
                "\\userAccountOne.json"));

        SolanaAccount userAccountTwo = SolanaAccount.fromSecret(KeyHelper.readSecretKeyFromFile("E:\\ABPES_concurrent" +
                "\\userAccountTwo.json"));

        AccountMeta userAccountMetaWithoutAssociation = new AccountMeta(accountWithoutAssociation.getPublicKey(),
                true, true);
        AccountMeta userAccountMetaOne = new AccountMeta(userAccountOne.getPublicKey(), true, true);
        AccountMeta userAccountMetaTwo = new AccountMeta(userAccountTwo.getPublicKey(), true, true);

        String sig = "example_signature";

        SolanaPublicKey rentSysvarPublicKey = new SolanaPublicKey("SysvarRent111111111111111111111111111111111");
        AccountMeta rentAccountMeta = new AccountMeta(rentSysvarPublicKey, false, false);

        client.getApi().requestAirdrop(accountWithoutAssociation.getPublicKey(), 10000000L);
        client.getApi().requestAirdrop(userAccountOne.getPublicKey(), 10000000L);
        client.getApi().requestAirdrop(userAccountOne.getPublicKey(), 10000000L);

        Instructions.DoNothingInstruction doNothingInstruction = new Instructions.DoNothingInstruction(0, sig);
        byte[] instructionDataDoNothing = doNothingInstruction.serialize();
        //doNothingInstruction.deserialize(new BufferedInputStream(new ByteArrayInputStream(instructionData)));

        Integer[] arr = getRandomArr(5);
        Instructions.SortInstruction sortInstruction = new Instructions.SortInstruction(0, Arrays.asList(arr), 0,
                arr.length - 1, sig);
        byte[] instructionDataSort = Instructions.SortInstruction.serializeInstruction(sortInstruction);

        Instructions.LoopInstruction loopInstruction = new Instructions.LoopInstruction(0, 0, Integer.MAX_VALUE, sig);
        byte[] instructionDataLoop = Instructions.LoopInstruction.serializeInstruction(loopInstruction);

        Instructions.MemoryInstruction memoryInstruction = new Instructions.MemoryInstruction(0, 2, 2, 65, 10, sig);
        byte[] instructionDataMemory = Instructions.MemoryInstruction.serializeInstruction(memoryInstruction);

        Instructions.RecursionInstruction recursionInstruction = new Instructions.RecursionInstruction(0, 0, 10, sig);
        byte[] instructionDataRecursion = Instructions.RecursionInstruction.serializeInstruction(recursionInstruction);

        //Instructions.KeyValueInstruction keyValueInstruction = new Instructions.KeyValueInstruction(1, "key", "value",
        // sig);
        Instructions.KeyValueInstruction keyValueInstruction = new Instructions.KeyValueInstruction(0, "key",
                sig);
        byte[] instructionDataKeyValue = Instructions.KeyValueInstruction.serializeInstruction(keyValueInstruction);

        Instructions.IOInstruction ioInstruction = new Instructions.IOInstruction(2, 2, 65, sig);
        byte[] instructionDataIo = Instructions.IOInstruction.serializeInstruction(ioInstruction);

        Instructions.SBCreateAccountInstruction sbCreateAccountInstruction =
                new Instructions.SBCreateAccountInstruction(6, "acct_id", 65, 123, sig);
        byte[] instructionDataSBCreateAccount =
                Instructions.SBCreateAccountInstruction.serializeInstruction(sbCreateAccountInstruction);

        Instructions.SBSendPaymentInstruction sbSendPaymentInstruction = new Instructions.SBSendPaymentInstruction(3,
                userAccountOne.getPublicKey().toByteArray(), userAccountTwo.getPublicKey().toByteArray(),
                "acct_idSender",
                "acct_idReceiver",
                3, sig);
        byte[] instructionDataSBSendPayment =
                Instructions.SBSendPaymentInstruction.serializeInstruction(sbSendPaymentInstruction);

        Instructions.SBAmalgamateInstruction sbAmalgamateInstruction = new Instructions.SBAmalgamateInstruction(5,
                userAccountOne.getPublicKey().toByteArray(), userAccountTwo.getPublicKey().toByteArray(), "acct_id0",
                "acct_id1",
                sig);
        byte[] instructionDataSBAmalgamate =
                Instructions.SBAmalgamateInstruction.serializeInstruction(sbAmalgamateInstruction);

        System.out.println("Serialized instructionData: " + Arrays.toString(instructionDataSBAmalgamate));
        System.out.println("Transaction Instruction: " + Base64.getEncoder().encodeToString(instructionDataSBAmalgamate));

        SolanaTransactionInstruction transactionInstruction = new SolanaTransactionInstruction(
                programId,
                // createAccount
                //new ArrayList<>(Arrays.asList(userAccountMetaOne, rentAccountMeta)),
                //amalgamate
                new ArrayList<>(Arrays.asList(userAccountMetaTwo, rentAccountMeta, userAccountMetaOne,
                        userAccountMetaTwo)),
                instructionDataSBAmalgamate
        );

        SolanaTransaction transaction = new SolanaTransaction().addInstruction(transactionInstruction);
        transaction.setFeePayer(userAccountMetaWithoutAssociation.getPublicKey());
        transaction.setRecentBlockHash(client.getApi().getRecentBlockhash());
        // createaccount
        //transaction.sign(new ArrayList(Arrays.asList(accountWithoutAssociation, userAccountTwo )));
        // amalgamate
        transaction.sign(new ArrayList<>(Arrays.asList(accountWithoutAssociation, userAccountTwo, userAccountOne)));

        try {
            final String eventService = "ws://192.168.178.124:20002";

            Cluster eventServiceCluster = Cluster.createCluster("EVENTSERVICE", eventService);
            SolanaWebSocketClient subscriptionWebSocketClient = new SolanaWebSocketClient(eventServiceCluster);
            //subscriptionWebSocketClient.connect();
            new Thread(() -> subscriptionWebSocketClient.logsSubscribe("all", SolanaCommitment.processed,
                    o -> System.out.println("Object: " + o))).start();

            String txSignature = client.getApi().sendTransaction(transaction, true);
            System.out.println("Tx Signature: " + txSignature);

            Cluster eventServiceClusterBlocks = Cluster.createCluster("EVENTSERVICEBLOCKS", eventService);
            SolanaWebSocketClient subscriptionWebSocketClientBlocks =
                    new SolanaWebSocketClient(eventServiceClusterBlocks);
            //subscriptionWebSocketClient.connect();
            new Thread(() -> subscriptionWebSocketClientBlocks.blockSubscribe("all", o -> System.out.println("Block: "
                    + o))).start();

            /*ConfirmedTransaction confirmedTransaction = client.getApi().getConfirmedTransaction(txSignature);
            System.out.println("Confirmed TX metadata:" + confirmedTransaction.getMeta().toString());*/
        } catch (Exception ex) {
            System.err.println("Error sending transaction: " + ex.getMessage());
        }

    }

    @NotNull
    private static Integer[] getRandomArr(final int size) {
        Random rd = new Random();
        Integer[] arr = new Integer[size];
        for (int i = 0; i < arr.length; i++) {
            arr[i] = Math.abs(rd.nextInt());
            System.out.println(arr[i]);
        }
        return arr;
    }

}
