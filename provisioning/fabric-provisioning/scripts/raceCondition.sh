#!/bin/bash

# An example scenario when this script should be evaluated and used is:
# There is one product left in an online shop
# The data of the online shop is stored in a Blockchain
# The values BATCH_TIMEOUT or MAX_MESSAGES are problematically set (see vars/common-vars.yaml)
# Two users try to buy the last product more or less simultaneously
# It can't be said which user will finally get the product
# This scenario needs further testing in order to get replicated  and can be mittigeted by setting MAX_MESSAGES to 1
# Setting MAX_MESSAGES to 1 can reduce performance so it might be wiser to evaluate the architecture of the client application and the Chaincode
# This means each Block only contains one transaction which will be taken
# If there are more than one transaction inside a block this problem can occur
# As the user does not know which values are set in the network configuration files
# he cannot predict when a Block will get written
# Afterwards you can check which value has been finally persisted the result may vary (depending on the set configuration) which implies a possible Race Condition

# Number of transactions to execute rapidly one after another
number=1
cli="cli.peerone.com"
orderer="orderer0.ordererone.com:27000"
ca="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/ordererone.com/orderers/orderer0.ordererone.com/msp/tlscacerts/tlsca.ordererone.com-cert.pem"
channel="testchannel"
# The name of the Chaincode
name="racecondition"
date=$(date +%s)
# The key in the World State / Blockchain
key="test-$date"

main() {

	printf "This tool can be used to gain a race condition when there are multiple transactions within a block.\nPlease adjust the variables in the script, beginning now:\n"
	for i in $(seq 1 $number);
	do
		args='{"Args":["persistValue", "'
		args+="$key"
		args+='","{ \"value\": \"'
		args+="$key-$i"
		args+='\" }"]}'
		echo "$args"
		docker exec $cli peer chaincode invoke -o $orderer --tls true --cafile $ca -C $channel -n $name -c "$args"
	done
} 

main "$@"

