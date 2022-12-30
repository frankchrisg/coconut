package client.blockchain;

import client.configuration.GeneralConfiguration;
import org.hibernate.cfg.NotYetImplementedException;

public class BlockchainStrategy {

    public static BlockchainFramework getBlockchainFramework() {
        switch (GeneralConfiguration.BLOCKCHAIN_FRAMEWORK) {
            case Corda:
                return BlockchainFramework.Corda;
            case Quorum:
                return BlockchainFramework.Quorum;
            case Ethereum:
                return BlockchainFramework.Ethereum;
            case Graphene:
                return BlockchainFramework.Graphene;
            case HyperledgerFabric:
                return BlockchainFramework.HyperledgerFabric;
            case HyperledgerSawtooth:
                return BlockchainFramework.HyperledgerSawtooth;
            case Diem:
                return BlockchainFramework.Diem;
            case Test:
                return BlockchainFramework.Test;
            default:
                throw new NotYetImplementedException("Not yet implemented blockchain framework defined");
        }
    }

    public static String getBlockchainFrameworkAsString() {
        switch (GeneralConfiguration.BLOCKCHAIN_FRAMEWORK) {
            case Corda:
                return "Corda";
            case Quorum:
                return "Quorum";
            case Ethereum:
                return "Ethereum";
            case Graphene:
                return "Graphene";
            case HyperledgerFabric:
                return "HyperledgerFabric";
            case HyperledgerSawtooth:
                return "HyperledgerSawtooth";
            case Diem:
                return "Diem";
            case Test:
                return "Test";
            default:
                throw new NotYetImplementedException("Not yet implemented blockchain framework defined");
        }
    }

}
