#!/bin/bash

# This script has been tested with Hyperledger Fabric version 1.3. Prior versions of Hyperledger Fabric may not be supported due to missing values like milliseconds per transaction.
# $1 is the peer name
# $2 is the channel name
# $3 is the path to the logfiles to create

# The separator used between values
separator=","

main() {
	if [ "$#" -ne 3 ]; then
		printf "This tool can be used to collect various statistical data.\nPlease use this tool exactly as following:\n"
		printf "\$1 should be peer domain name to use\n"
		printf "\$2 should be the channel name to use\n"
		printf "\$3 should be the path to logfiles\n"
		exit 1
	else
		printf "Start writing logfiles\n"
		logFilePath="$3"

		statsValidation=$(docker logs "$1" 2>&1 | grep -E "$2" | grep -Eo "Validated block \[[0-9]+\] in ([0-9]+ms)" | grep -Eo "\[[0-9]+\]|([0-9]+ms)")

		statsCommit=$(docker logs "$1" 2>&1 | grep -E "$2" | grep -Eo "Committed block \[[0-9]+\] with [0-9]+ transaction\(s\) in ([0-9]+ms) \(state_validation=([0-9]+ms) block_commit=([0-9]+ms) state_commit=([0-9]+ms)\)")

		statsCommitGenesis=$(echo "$statsCommit" | grep -E "Committed block \[0\] with [0-9]+ transaction\(s\) in ([0-9]+ms) \(state_validation=([0-9]+ms) block_commit=([0-9]+ms) state_commit=([0-9]+ms)\)" | grep -Eo "\[[0-9]+\]|[0-9]+|([0-9]+ms)|([0-9]+ms)|([0-9]+ms)")

		statsCommitExcludeGenesis=$(echo "$statsCommit" | grep -v "\[0\]" | grep -Eo "\[[0-9]+\]|[0-9]+|([0-9]+ms)|([0-9]+ms)|([0-9]+ms)")

		statsValidationLength=$(echo "$statsValidation" | tr ' ' '\n' | wc -l)

		statsCommitExcludeGenesisLength=$(echo "$statsCommitExcludeGenesis" | tr ' ' '\n' | wc -l)
		statsCommitExcludeGenesisLength=$((statsCommitExcludeGenesisLength / 3))

		if [ ! "$statsValidationLength" == "$statsCommitExcludeGenesisLength" ]; then
			printf "aborting, because statsValidationLength: %s not equals statsCommitLength:\n %s" "$statsValidationLength" "$statsCommitExcludeGenesisLength"
			echo "$statsValidation"
			echo "$statsCommitExcludeGenesis"
			if [ "$statsCommitExcludeGenesisLength" == 0 ]; then
				echo "Please initialize the Blockchain with at least one block beside the genesis block"
			fi
		else
			printf "Continuing with writing stats to files\n"

			header=("blockNr" "transactionsInBlock" "timeToCommit" "stateValidation" "blockCommit" "stateCommit")
			writeHeader "statsCommitGenesis-$1.txt" 6 "${header[@]}"
			writeHeader "statsCommitExcludeGenesis-$1.txt" 6 "${header[@]}"
			header=("blockNr" "validationTime")
			writeHeader "statsValidation-$1.txt" 2 "${header[@]}"

			writeRecords "statsCommitGenesis-$1.txt" "$statsCommitGenesis" 6
			writeRecords "statsCommitExcludeGenesis-$1.txt" "$statsCommitExcludeGenesis" 6
			writeRecords "statsValidation-$1.txt" "$statsValidation" 2

			printf "Done writing files\n"
			exit 0
		fi

	fi
}

writeHeader() {
	j=1
	echo -n "" > "$logFilePath/$1"
	for i in "${@:3}"
	do
		if [ $(( j % $2 )) -eq 0 ] ; then
			printf "\"%s\"\n" "$i" >> "$logFilePath/$1"
		else
			printf "\"%s\"%s" "$i" "$separator" >> "$logFilePath/$1"
		fi
		((j++))
	done
}

writeRecords () {
	i=1
	s=""
	while read -r line; do
		if [ $(( i % $3 )) -eq 0 ] ; then
			s+=$(printf "\"%s\"\n" "$line" | tr -d "[" | tr -d "ms"  | tr -d "]")
			s+=$'\n'
		else
			s+=$(printf "\"%s\"%s" "$line" "$separator" | tr -d "[" | tr -d "ms"  | tr -d "]")
		fi
		((i++))
	done <<< "$2"
	echo "$s" >> "$logFilePath/$1"
}

main "$@"
