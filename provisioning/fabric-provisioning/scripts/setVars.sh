#!/bin/bash

# $1 is the organization domain name to use
# $2 is the peer number to use
# $3 is the port number to use
# $4 is the organization name from the MSP directive

# This script might be used to set peer information as environment variables for further execution of steps within the cli (e.g. channel creation etc.)

main() {
	if [ "$#" -ne 4 ] || ! [[ "$2" =~ ^[0-9]+$ ]]  || ! [[ "$3" =~ ^[0-9]+$ ]]; then
		printf "This tool can be used to provide the cli with data.\nPlease use this tool exactly as following:\n"
		printf "To export the variables use this script with \"source\" or \".\"\n"
		printf "\$1 should be the organization domain name to use\n"
		printf "\$2 should be the peer number to use\n"
		printf "\$3 should be the port number to use\n"
		printf "\$4 should be the organization name from the MSP directive\n"
		exit 1
	else
		export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$1/users/Admin@$1/msp
		export CORE_PEER_ADDRESS=peer$2.$1:$3
		export CORE_PEER_LOCALMSPID=$4
		export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/$1/peers/peer$2.$1/tls/ca.crt

		printf "Values have been set to:\n"
		printf "CORE_PEER_MSPCONFIGPATH:\n%s\n" "$CORE_PEER_MSPCONFIGPATH"
		printf "CORE_PEER_ADDRESS:\n%s\n" "$CORE_PEER_ADDRESS"
		printf "CORE_PEER_LOCALMSPID:\n%s\n" "$CORE_PEER_LOCALMSPID"
		printf "CORE_PEER_TLS_ROOTCERT_FILE:\n%s\n" "$CORE_PEER_TLS_ROOTCERT_FILE"
	fi
}

main "$@"
