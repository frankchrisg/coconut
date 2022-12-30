#!/bin/bash
# This script can be used to update the channel configuration
# Adapted from: https://medium.com/coinmonks/hyperledger-fabric-updating-channel-configs-45082a5dc9b2
# For further information see: https://hyperledger-fabric.readthedocs.io/en/release-1.4/config_update.html
# You can execute the script with sh -x to get further debugging output
# Watch the error logs carefully, as such messages could occure:
# configtxlator: error: Error computing update: error computing config update: no differences detected between original and updated config
# Please adjust the following variables
CHANNEL_NAME="testchannel"
ORDERER_CA="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/ordererone.com/orderers/orderer0.ordererone.com/msp/tlscacerts/tlsca.ordererone.com-cert.pem"
PREFERRED_CLI="cli.peerone.com"
ORDERER_ADDRESS_FULL="orderer0.ordererone.com:27000"
OLD_VALUE="\"max_message_count\": 1000"
NEW_VALUE="\"max_message_count\": 10"

docker exec -i "$PREFERRED_CLI" peer channel fetch config config_block.pb -o "$ORDERER_ADDRESS_FULL" -c "$CHANNEL_NAME" --tls --cafile "$ORDERER_CA"
docker exec -i "$PREFERRED_CLI" bash -c "configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json"
docker exec -i "$PREFERRED_CLI" cp config.json modified_config.json
docker exec -i "$PREFERRED_CLI" sed -i "s/$OLD_VALUE/$NEW_VALUE/g" modified_config.json
docker exec -i "$PREFERRED_CLI" configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
docker exec -i "$PREFERRED_CLI" configtxlator proto_encode --input config.json --type common.Config --output config.pb
docker exec -i "$PREFERRED_CLI" configtxlator compute_update --channel_id "$CHANNEL_NAME" --original config.pb --updated modified_config.pb --output diff_config.pb
docker exec -i "$PREFERRED_CLI" bash -c "configtxlator proto_decode --input diff_config.pb --type common.ConfigUpdate | jq . > diff_config.json"
TEMP_DIFF_CONFIG=$(docker exec -i cli.peerone.com cat diff_config.json|tr '\n' ' ')
docker exec -i "$PREFERRED_CLI" bash -c "echo '{\"payload\":{\"header\":{\"channel_header\":{\"channel_id\":\"$CHANNEL_NAME\", \"type\":2}},\"data\":{\"config_update\":$TEMP_DIFF_CONFIG}}}' | jq . > diff_config_envelope.json"
docker exec -i "$PREFERRED_CLI" configtxlator proto_encode --input diff_config_envelope.json --type common.Envelope --output diff_config_envelope.pb
docker exec -i "$PREFERRED_CLI" peer channel signconfigtx -f diff_config_envelope.pb
docker exec -i "$PREFERRED_CLI" peer channel update -f diff_config_envelope.pb -c "$CHANNEL_NAME" -o "$ORDERER_ADDRESS_FULL" --tls --cafile "$ORDERER_CA"
docker exec -i "$PREFERRED_CLI" bash -c "rm -rf *.pb *.json"
