package diem.workloads;

import client.commoninterfaces.IListenerDisconnectionLogic;
import client.commoninterfaces.IWorkloadObject;
import client.database.Connection;
import client.supplements.ExceptionHandler;
import co.paralleluniverse.fibers.Suspendable;
import com.diem.DiemClient;
import diem.configuration.Configuration;
import diem.helper.AccountInformation;
import diem.helper.Helper;
import diem.payloads.IDiemReadPayload;
import diem.payloads.IDiemWritePayload;
import org.apache.log4j.Logger;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.atomic.AtomicLong;

public class PrepareDiemWorkloadObject implements IWorkloadObject {

    private static final Logger LOG = Logger.getLogger(PrepareDiemWorkloadObject.class);

    private final Map<String, String> listener = Collections.synchronizedMap(new LinkedHashMap<>());
    private final Queue<IListenerDisconnectionLogic> iListenerDisconnectionLogicList = new ConcurrentLinkedQueue<>();
    private String signature;
    private List<List<IDiemWritePayload>> completeWritePayloadList;
    private List<List<IDiemReadPayload>> completeReadPayloadList;

    public Map<String, List<AccountInformation>> getAccountInformationMap() {
        return accountInformationMap;
    }

    private final Map<String, List<AccountInformation>> accountInformationMap =
            Collections.synchronizedMap(new LinkedHashMap<>());

    public DiemClient getDiemClient() {
        return diemClient;
    }

    public void setDiemClient(final DiemClient diemClient) {
        this.diemClient = diemClient;
    }

    private DiemClient diemClient;

    public Map<String, String> getListener() {
        return listener;
    }

    public List<List<IDiemWritePayload>> getDiemWritePayloads() {
        return completeWritePayloadList;
    }

    public void setDiemWritePayloads(final List<List<IDiemWritePayload>> iDiemWritePayloads) {
        this.completeWritePayloadList = iDiemWritePayloads;
    }

    public List<List<IDiemReadPayload>> getDiemReadPayloads() {
        return completeReadPayloadList;
    }

    public void setDiemReadPayloads(final List<List<IDiemReadPayload>> iDiemReadPayloads) {
        this.completeReadPayloadList = iDiemReadPayloads;
    }

    public String getSignature() {
        return signature;
    }

    public void setSignature(final String signature) {
        this.signature = signature;
    }

    public Queue<IListenerDisconnectionLogic> getIListenerDisconnectionLogicList() {
        return iListenerDisconnectionLogicList;
    }

    @Suspendable
    public static synchronized void setNonce(final DiemClient client, final String address) {

        AtomicLong nonce;
        try {
            nonce = Helper.getNonce(client, address);

            if (Configuration.DISTRIBUTED_NONCE_HANDLING) {

                try (java.sql.Connection connection = Connection.getConnection()) {
                    String query = "INSERT INTO diem_nonce AS dn (address, nonce)" +
                            "VALUES (?, ?)" +
                            "ON CONFLICT (address) DO NOTHING " +
                            "RETURNING nonce";

                    PreparedStatement preparedStatement = connection.prepareStatement(query);
                    preparedStatement.setString(1, address);
                    preparedStatement.setLong(2, nonce.get());

                    ResultSet resultSet = preparedStatement.executeQuery();

                    int i = 0;
                    while (resultSet.next()) {
                        LOG.info("Current nonce: " + resultSet.getInt("nonce"));
                        i++;
                    }
                    if (i == 0) {
                        LOG.info("Result set was empty");
                    }

                    resultSet.close();
                    preparedStatement.close();
                } catch (SQLException ex) {
                    ExceptionHandler.logException(ex);
                }
            }
        } catch (Exception ex) {
            ExceptionHandler.logException(ex);
        }
    }
}
