package graphene.listener;

import client.client.ClientObject;
import client.statistics.IStatistics;

import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedQueue;

public class BlockListObject {

    private final Queue<ClientObject> clientObjectQueue;

    private final int blockId;

    private final String webSocketAddress;

    private final Queue<IStatistics> iStatistics = new ConcurrentLinkedQueue<>();

    public BlockListObject(final Queue<ClientObject> clientObjectQueueConstructor,
                           final int blockIdConstructor, final String webSocketAddressConstructor) {
        this.clientObjectQueue = clientObjectQueueConstructor;
        this.blockId = blockIdConstructor;
        this.webSocketAddress = webSocketAddressConstructor;
    }

    public int getBlockId() {
        return blockId;
    }

    public String getWebSocketAddress() {
        return webSocketAddress;
    }

    public Queue<IStatistics> getiStatistics() {
        return iStatistics;
    }

    public Queue<ClientObject> getClientObjectQueue() {
        return clientObjectQueue;
    }
}
