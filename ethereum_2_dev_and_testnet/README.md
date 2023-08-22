The process for initiating a private Eth2 (Ethereum) proof of stake (PoS) devnet/testnet is currently under-documented, leaving many developers in need of guidance. To address this gap, we present a set of  guidelines to streamline the setup.
These guideline require some basic knowledge of the programs described.
Using one of the listed programs requires to download or clone the associated repository.

---
### Prysm
To run Prysm, the following versions have been tested:
Geth version: e2507a17e8df5bb84b4b1195cf6a2d58e3ba109c
Prysm version: e545b57f260837e14317248cfda046616431b8a3 (https://github.com/prysmaticlabs/prysm)

Notes:
- you can use the Ethereum v1 provisioning provided by COCONUT
- do not forget to adjust the jwtsecret files created by geth accordingly
- set the genesis time long enough to start from slot 0, see the parameter genesis-time for genesis creation

Build the binaries:

`cd prysm`

`go build -o=../beacon-chain ./cmd/beacon-chain`

`go build -o=../validator ./cmd/validator`

`go build -o=../prysmctl ./cmd/prysmctl`

`cd ..`

Generate a genesis, specify the number of validators to use:

`./prysmctl testnet generate-genesis --num-validators=80 --output-ssz=genesis.ssz --chain-config-file=config.yml --override-eth1data=true -execution-endpoint "http://192.168.178.137:30000" --genesis-time=$(( $(date +%s) + 20 ))`

Start the beacon-chain and the validator for one node:

`./beacon-chain --datadir=beacondata --min-sync-peers=0 --genesis-state=genesis.ssz --chain-config-file=config.yml --config-file=config.yml --chain-id=10 --execution-endpoint=http://192.168.178.137:15000 --accept-terms-of-use --jwt-secret=jwtsecret --contract-deployment-block=0 --force-clear-db`

`./validator --datadir=validatordata --accept-terms-of-use --interop-num-validators=40 --interop-start-index=0 --force-clear-db --chain-config-file=config.yml --config-file=config.yml`

Export the address of the peer:

`export PEER=$(curl -s localhost:8080/p2p | perl -nle 'print $& if m{(/ip4/\d+\.\d+\.\d+\.\d+/tcp/\d+/p2p/[^,]+)}')`

Start the second beacon-chain and the second validator for another node:

`./beacon-chain --datadir=beacondata2 --min-sync-peers=1 --genesis-state=genesis.ssz --chain-config-file=config.yml --config-file=config.yml --chain-id=10 --execution-endpoint=http://localhost:15100 --accept-terms-of-use --rpc-port=4001 --p2p-tcp-port=13001 --p2p-udp-port=12001 --grpc-gateway-port=3501 --monitoring-port=8001 --jwt-secret=jwtsecret2 --peer=$PEER --force-clear-db`

`./validator --datadir=validatordata2 --accept-terms-of-use --interop-num-validators=40 --interop-start-index=0 --force-clear-db --chain-config-file=config.yml --config-file=config.yml --beacon-rest-api-provider=http://127.0.0.1:3501  --beacon-rpc-gateway-provider=http://127.0.0.1:3501 --beacon-rpc-provider=127.0.0.1:4001`

That's it, verify block creation. Adjust further parameters according to your needs.

---
### Lighthouse
To run Lighthouse, the following versions have been tested:
Geth version: e2507a17e8df5bb84b4b1195cf6a2d58e3ba109c
Lighthouse: 59c24bcd2d83f1fcafc6ee4db9cf7b6f88ed7459 (https://github.com/sigp/lighthouse)

Notes:
- you can use the Ethereum v1 provisioning provided by COCONUT
- do not forget to adjust the jwtsecret files created by geth accordingly
- remove any created node directories, like rm -rf node0 node1
- adjust the "-b" value to the enr obtained for the first node
- we provide a slightly modified beacon_node.sh file used in the scripts/local_testnet/ directory to start the beacon-nodes
- adjust vars.env, like the variable BN_COUNT

Build the binaries running:

`make && make install`

Run the scripts clean.sh and setup.sh in scripts/local_testnet/, like:

`./clean.sh && ./setup.sh`

Start the beacon-chain and the validator for one node:

`bash -x beacon_node.sh node0 59100 58100 http://192.168.178.137:15000 jwt`

`bash -x validator_client.sh /home/parallels/.lighthouse/local-testnet/node_1/ http://127.0.0.1:58100`

Get the enr of the first node:

`curl http://localhost:58100/eth/v1/node/identity | jq`

Start the second beacon-chain and the second validator for another node (replace the enr with the one previously obtained):

`bash -x beacon_node.sh -b enr:-Ly4QIJtuzgmTbr-KEz3rFnDsayGhETI7gGFIKbajdvzP1SqAfMMJOz-W5qxDEBByI1L4s6zPaSTbPnGyyW3NdFTGGUHh2F0dG5ldHOIgAEAAAAAAACEZXRoMpAu7z7IAwAAAAD2AgAAAAAAgmlkgnY0gmlwhH8AAAGJc2VjcDI1NmsxoQK-i6MmqUttdjZE4At0UnluYVlnM5oNZOa1mvFxIHOquohzeW5jbmV0cw-DdGNwgubcg3VkcILm3A node1 59200 58200 http://192.168.178.137:15100 jwt2`

`bash -x validator_client.sh /home/parallels/.lighthouse/local-testnet/node_2/ http://127.0.0.1:58200`

That's it, verify block creation. Adjust further parameters according to your needs.

---
### Teku
To run Teku, the following versions have been tested:
Geth version: e2507a17e8df5bb84b4b1195cf6a2d58e3ba109c
Teku version: b54882aae2389f8bddd7522076b1c982401017d5 (https://github.com/Consensys/teku)

Notes:
- you can use the Ethereum v1 provisioning provided by COCONUT
- do not forget to adjust the jwtsecret files created by geth accordingly
- to bootstrap the validators, we use Lighthouse to create the necessary validators
- set the genesis time long enough to start from slot 0, see the parameter genesis-time for genesis creation
- we provide an adjusted template for the mainnet.yaml
- adjust the copyvalidators.sh file in the provided directory

Run gradlew in the source directory of Teku:

`./gradlew installDist`

Switch to the directory of the compiled file:

`cd ./build/install/teku/bin`

Adjust the file (a rebuild might be required):

`nano ../../../../ethereum/spec/src/main/resources/tech/pegasys/teku/spec/config/configs/mainnet.yaml`

Create the validator files from Lighthouse a described in the Lighthouse instructions above in another terminal:

`./clean.sh && ./setup.sh`

Delete all previously created files and run the script to copy the validator data created by Lighthouse:

`rm -rf ../../../../val1/* && bash ../../../../copyvalidators.sh /home/parallels/.lighthouse/local-testnet/node_1/validators 1`

`rm -rf ../../../../val2/* && bash ../../../../copyvalidators.sh /home/parallels/.lighthouse/local-testnet/node_2/validators 2`

Remove any created teku files and mock the genesis file:

`rm -rf /home/parallels/.local/share/teku/`

`rm -rf /home/parallels/.local/share/teku2/`

`./teku genesis mock -o genesis.szz -v 80 --genesis-time=$(( $(date +%s) + 30 ))`

Start the beacon-chain and the validator for one node:

`./teku --p2p-advertised-ip=127.0.0.1 --ee-jwt-secret-file=/home/parallels/jwtsecret.hex  --metrics-enabled=true --p2p-port=12700 --rest-api-enabled=true --eth1-deposit-contract-address=0x4242424242424242424242424242424242424242 --validators-proposer-default-fee-recipient=0x123463a4b065722e99115d6c222f267d9cabb524 -l DEBUG --eth1-endpoint=http://localhost:30000 --ee-endpoint=http://localhost:15000 --p2p-enabled=true --deposit-snapshot-enabled=false --initial-state=genesis.szz`

`./teku vc --validator-keys=/home/parallels/FINAL_graphene_corda_latest_xxx/teku/val1:/home/parallels/FINAL_graphene_corda_latest_xxx/teku/val1 --validators-proposer-default-fee-recipient=0x123463a4b065722e99115d6c222f267d9cabb524`

Get the enr of the first node:

`curl -X GET "http://localhost:5051/eth/v1/node/identity`

Start the second beacon-chain and the second validator for another node (replace the enr with the one previously obtained):

`./teku --p2p-advertised-ip=127.0.0.1 --p2p-discovery-bootnodes=enr:-LK4QJbZTIE5GjZvO44HYBCDyHqFAnBpBg8ab5zp4P7gCRRXIBH_6vB1I1F2bwptpvJc6bMtUKT60go_gnIKH_7C_0UEh2F0dG5ldHOIAQAAAAAAAICEZXRoMpCKaIOuAQAAAAIAAAAAAAAAgmlkgnY0gmlwhH8AAAGJc2VjcDI1NmsxoQL7o9jihEqiLlEkJIi29Won7vHPSnuUjJjOPbPfJxmxf4N0Y3CCMZyDdWRwgjGc --data-base-path=/home/parallels/.local/share/teku2 --ee-jwt-secret-file=/home/parallels/jwtsecret2.hex --rest-api-port=5053 --metrics-enabled=false --p2p-port=13700 --rest-api-enabled=true --eth1-deposit-contract-address=0x4242424242424242424242424242424242424242 --validators-proposer-default-fee-recipient=0x123463a4b065722e99115d6c222f267d9cabb524 -l DEBUG --eth1-endpoint=http://localhost:30100 --ee-endpoint=http://localhost:15100 --p2p-enabled=true --deposit-snapshot-enabled=false --initial-state=genesis.szz`

`./teku vc --validator-api-port=5054 --data-base-path=/home/parallels/.local/share/teku2 --beacon-node-api-endpoint=http://localhost:5053 --validator-keys=/home/parallels/FINAL_graphene_corda_latest_xxx/teku/val2:/home/parallels/FINAL_graphene_corda_latest_xxx/teku/val2 --validators-proposer-default-fee-recipient=0x123463a4b065722e99115d6c222f267d9cabb524`

That's it, verify block creation. Adjust further parameters according to your needs.

---
### Lodestar
To run Lodestar, the following versions have been tested:
Geth version: e2507a17e8df5bb84b4b1195cf6a2d58e3ba109c
Lodestar version: 7546292ef150c37a9a912b349d51f8ea59f686fb (https://github.com/ChainSafe/lodestar)

Notes:
- you can use the Ethereum v1 provisioning provided by COCONUT
- do not forget to adjust the jwtsecret files created by geth accordingly
- set the genesis time long enough to start from slot 0, see the parameter genesisTime for genesis creation
- create the directory add_conf and add the config.yaml from our provided files
- the file pwd used with the parameter passphraseFile contains only the string 
**test_password**
- pay attention for the parameter -\-enr.ip, otherwise beacon-node connection might not work
- pay attention for the parameters -\-sync.isSingleNode=true -\-network.allowPublishToZeroPeers=true used with the first beacon-node
-\-pay attention for the parameter -\-network.connectToDiscv5Bootnodes true used with the second beacon-node
- you can build the Dockerfile provided and run the container which builds Lodestar using: docker run -\-network host -it -v $(pwd):/app  lodestar-app /bin/bash

Delete any lodestar directories and the associated config directories on every node:

`rm -rf /root/.local/share/lodest*`

`rm -rf add_conf/keystores* add_conf/secrets`

Create a genesis file:

`./lodestar dev --dumpTestnetFiles add_conf --genesisValidators 80 --genesisTime $(( $(date +%s) + 60 )) --paramsFile=add_conf/config.yaml --reset`

Run the movedirs script from our provided files to separate the created keystores for multiple nodes:

`bash -x movedirs.sh add_conf/keystores 40 add_conf/keystores2`

Run a dev instance for the beacon-node and the validator just once (currently creating the genesis file does not set the genesisTime):

`./lodestar dev --genesisValidators 80 --genesisTime $(( $(date +%s) + 60 )) --paramsFile=add_conf/config.yaml --port 17779`

Abort the execution using something like:

`CTRL + C`

Start the beacon-chain and the validator for one node:

`./lodestar beacon --eth1 --eth1.providerUrls http://localhost:30000 --port 21333 --execution.urls http://localhost:15000 --jwt-secret jwt --rest --listenAddress 127.0.0.1 --enr.ip 127.0.0.1 --dataDir /root/.local/share/lodestar --rest.port 7778 --paramsFile=add_conf/config.yaml --network=dev --genesisStateFile=genesis.ssz --sync.isSingleNode=true --network.allowPublishToZeroPeers=true`

`./lodestar validator --paramsFile=add_conf/config.yaml --network=dev --keystore=add_conf/keystores/ --passphraseFile=pwd --dataDir /root/.local/share/lodestar --beaconNodes http://localhost:7778`

Get the enr of the first node:

`curl http://localhost:7778/eth/v1/node/identity`

Start the second beacon-chain and the second validator for another node (replace the enr with the one previously obtained):

`./lodestar beacon --port 21334 --execution.urls http://localhost:15100 --jwt-secret jwt2 --rest --listenAddress 127.0.0.1 --enr.ip 127.0.0.1 --dataDir /root/.local/share/lodestar2 --rest.port 7779 --paramsFile=add_conf/config.yaml --network=dev --genesisStateFile=genesis.ssz --network.connectToDiscv5Bootnodes true --bootnodes "enr:-LK4QB5t1UlUJBt_uwKDNvwI8Jttob2__9aNRb1SZ6qWZ3JYFi0tqxyH_qnGH4u2ew2J-gYBDa7FieILkczsmtFP-LkJh2F0dG5ldHOIAAAAAAAAMACEZXRoMpCfx3dAAQAAAQoAAAAAAAAAgmlkgnY0gmlwhH8AAAGJc2VjcDI1NmsxoQPDQL225uz1F4qcTT_uC-4eMgyIpEQadZofX8LdvfU3u4N0Y3CCU1WDdWRwglNV"`

`./lodestar validator --paramsFile=add_conf/config.yaml --network=dev --keystore=add_conf/keystores2/ --passphraseFile=pwd --dataDir /root/.local/share/lodestar2 --beaconNodes http://localhost:7779`

That's it, verify block creation. Adjust further parameters according to your needs.

---
### Nimbus
To run Nimbus, the following versions have been tested:
Nimbus version: 1bc9f3a67ac519ab4f889ca19abfd74f5e07c205 (https://github.com/status-im/nimbus-eth2)
Geth: Custom from https://github.com/status-im/nimbus-simulation-binaries/releases

Notes:
- you **cannot** use the Ethereum v1 provisioning provided by COCONUT
- do not forget to adjust the jwtsecret files created by geth accordingly
- set the genesis time long enough to start from slot 0, see the parameter genesis-time for genesis creation

To build the binary, run:

`make -j 8 LOG_LEVEL=TRACE 'NIMFLAGS= -d:local_testnet -d:const_preset=minimal -d:web3_consensus_const_preset=minimal -d:FIELD_ELEMENTS_PER_BLOB=4' ncli_testnet nimbus_light_client nimbus_signing_node nimbus_validator_client nimbus_beacon_node`

To get some bootstrap files, run (you may abort execution, when all bootstrap files are present):

`bash -x scripts/launch_local_testnet.sh --data-dir xxxxp --preset minimal --nodes 2 --capella-fork-epoch 3 --deneb-fork-epoch 20 --stop-at-epoch 10 --disable-htop --base-port 5011 --base-rest-port 6011 --base-metrics-port 7011 --base-el-net-port 8011 --base-el-rpc-port 9011 --base-el-ws-port 10111 --base-el-auth-rpc-port 11111 --el-port-offset 5 --disable-vc --reuse-binaries --run-geth --dl-geth -- --verify-finalization`

Remove any unneeded files:

`rm -rf xxxx2/geth-0/ xxxx2/node1/ xxxx2/validators/* xxxx2/secrets/* xxxx3/ xxxx2/node2/`

\# the most needed files in the xxxx2 directory are *execution_genesis.json*, *execution_genesis_block.json*, *config.toml*, *config.yaml*, *keymanager-token*, *network_key.json*, *deposit_contract_block.txt*, *deposit_contract_block_hash.txt* and *deposit_contract.txt*

Generate the deposits:

`./build/ncli_testnet generateDeposits --count=80 --out-validators-dir=xxxx2/validators --out-secrets-dir=xxxx2/secrets --out-deposits-file=xxxx2/deposits.json --threshold=1 --remote-validators-count=0`

Bootstrap both geth nodes as you would do with geth normally:

`/home/parallels/FINAL_graphene_corda_latest_xxx/nimbus-eth2/build/downloads/geth_capella --datadir xxxx2/geth-0 init xxxx2/execution_genesis.json`

`/home/parallels/FINAL_graphene_corda_latest_xxx/nimbus-eth2/build/downloads/geth_capella --syncmode full --networkid 20101 --datadir xxxx2/geth-0 --nodiscover --http --http.port 30000 --port 25000 --authrpc.port 15000 --authrpc.jwtsecret xxxx2/jwtsecret`

`/home/parallels/FINAL_graphene_corda_latest_xxx/nimbus-eth2/build/downloads/geth_capella --datadir xxxx3/geth-0 init xxxx2/execution_genesis.json`

`/home/parallels/FINAL_graphene_corda_latest_xxx/nimbus-eth2/build/downloads/geth_capella --syncmode full --networkid 20101 --datadir xxxx3/geth-0 --nodiscover --http --http.port 30001 --port 25001 --authrpc.port 15001 --authrpc.jwtsecret xxxx3/jwtsecret`

Add the peers to each other, replace 8\.192\.177\.168 with the intended IP:

`PEER=$(/home/parallels/FINAL_graphene_corda_latest_xxx/nimbus-eth2/build/downloads/geth_capella attach --datadir xxxx2/geth-0 --exec admin.nodeInfo.enode | sed 's/8\.192\.177\.168/127.0.0.1/')`

`PEERX=$(/home/parallels/FINAL_graphene_corda_latest_xxx/nimbus-eth2/build/downloads/geth_capella attach --datadir xxxx3/geth-0 --exec admin.nodeInfo.enode | sed 's/8\.192\.177\.168/127.0.0.1/')`

`/home/parallels/FINAL_graphene_corda_latest_xxx/nimbus-eth2/build/downloads/geth_capella attach --datadir xxxx2/geth-0 --exec "admin.addPeer($PEER)"`

`/home/parallels/FINAL_graphene_corda_latest_xxx/nimbus-eth2/build/downloads/geth_capella attach --datadir xxxx2/geth-0 --exec "admin.addPeer($PEERX)"`

`/home/parallels/FINAL_graphene_corda_latest_xxx/nimbus-eth2/build/downloads/geth_capella attach --datadir xxxx3/geth-0 --exec "admin.addPeer($PEER)"`

`/home/parallels/FINAL_graphene_corda_latest_xxx/nimbus-eth2/build/downloads/geth_capella attach --datadir xxxx3/geth-0 --exec "admin.addPeer($PEERX)"`

Create the genesis file:

`./build/ncli_testnet createTestnet --data-dir=xxxx2 --deposits-file=xxxx2/deposits.json --total-validators=80 --output-genesis=xxxx2/genesis.ssz --output-bootstrap-file=xxxx2/bootstrap_nodes.txt --output-deposit-tree-snapshot=xxxx2/deposit_tree_snapshot.ssz --bootstrap-address=127.0.0.1 --bootstrap-port=5011 --netkey-file=network_key.json --insecure-netkey-password=true --genesis-time=$(( $(date +%s) + 30 )) --execution-genesis-block=xxxx2/execution_genesis_block.json`

Split the validators into multiple directories:

`bash -x movedirs.sh xxxx2/validators/ 40 xxxx3/validators && bash -x movedirs.sh xxxx2/secrets/ 40 xxxx3/secrets`

Run the first beacon-node and validator in one command:

`./build/nimbus_beacon_node --config-file=xxxx2/config.toml  --tcp-port=5011 --udp-port=5011 --max-peers=1 --data-dir=xxxx2/node1 --netkey-file=network_key.json --insecure-netkey-password=true --subscribe-all-subnets --jwt-secret=xxxx2/jwtsecret --web3-url=http://127.0.0.1:15000 --payload-builder=false --payload-builder-url=http://127.0.0.1:4888 --light-client-data-serve=on --light-client-data-import-mode=full --light-client-data-max-periods=999999 --keymanager-token-file=xxxx2/keymanager-token --finalized-deposit-tree-snapshot=xxxx2/deposit_tree_snapshot.ssz --rest-port=6011 --metrics-port=7011 --doppelganger-detection=off --validators-dir=xxxx2/validators --secrets-dir=xxxx2/secrets --enr-auto-update`

Get the enr of the first node:

`curl -X GET http://localhost:6011/eth/v1/node/identity`

Save the output to the file (overwrite the file, if there are any previous addresses):

`xxxx2/bootstrap_nodes.txt`

Run the second beacon-node and validator in one command:

`./build/nimbus_beacon_node --config-file=xxxx2/config.toml  --tcp-port=5012 --udp-port=5012 --max-peers=2 --data-dir=xxxx2/node2 --netkey-file=network_key.json --insecure-netkey-password=true --subscribe-all-subnets --jwt-secret=xxxx3/jwtsecret --web3-url=http://127.0.0.1:15001 --payload-builder=false --payload-builder-url=http://127.0.0.1:4888 --light-client-data-serve=on --light-client-data-import-mode=full --light-client-data-max-periods=999999 --keymanager-token-file=xxxx2/keymanager-token --finalized-deposit-tree-snapshot=xxxx2/deposit_tree_snapshot.ssz --rest-port=6012 --metrics-port=7012 --doppelganger-detection=off --validators-dir=xxxx3/validators --secrets-dir=xxxx3/secrets --bootstrap-file=xxxx2/bootstrap_nodes.txt --enr-auto-update`

That's it, verify block creation. Adjust further parameters according to your needs.

---

To check block creation you can attach to a geth instance like this:

`/home/parallels/FINAL_graphene_corda_latest_xxx/nimbus-eth2/build/downloads/geth_capella attach /home/parallels/FINAL_graphene_corda_latest_xxx/nimbus-eth2/xxxx2/geth-0/geth.ipc`

check for the height of the chain using the command:

`eth.blockNumber`

or check for the block data, like:

`eth.getBlock(71)`

this could be useful to check different nodes to sync the same blocks
