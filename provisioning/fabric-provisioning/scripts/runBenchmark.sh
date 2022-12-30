#!/bin/bash

# $1 is the path to the jar file
# $2 is the jar file
# $3 is the class to use
# $4 is the logpath
# $5 is the hostname
# $6 should be the CA file (including path)
# $7 is the maximum number of client-threads
# $8 is the number of reruns

# This script might be used to start the benchmarking-client multiple times Due to an extensive resource usage problems can occur during continual execution
# The Hyperledger Fabric Java Standard Development Kit should be further analyzed
# It is supposed that something like a memory leak could cause the problematic behaviour

STARTING_THREADS=10

main() {
	if [[ "$#" -lt 8 ]] || [[ "$#" -gt 10 ]]; then
		printf "This tool can be used to start the benchmarking-client multiple times.\nPlease use this tool exactly as following:\n"
		printf "\$1 should be the path to the jar\n"
		printf "\$2 should be the jar file\n"
		printf "\$3 should be the class to use\n"
		printf "\$4 should be the logpath\n"
		printf "\$5 should be the hostname of the current machine or any other remarkable value\n"
		printf "\$6 should be the CA file (including path)\n"
		printf "\$7 should be the number of maximum client-threads\n"
		printf "\$8 should be the number of reruns \n"
		printf "Optional:\n"
		printf "\$9 should be the channel name \n"
		printf "\$10 should be the number of fixed threads \n"
		exit 1
	else
		while [[ "$STARTING_THREADS" -le "$7" ]]; do
			for i in $(seq 1 "$8"); do
				if [[ "$#" -eq 8 ]]; then
				echo "java -cp \"$1\"/\"$2\" \"$3\" \"$4\" \"$5\" \"$6\" \"$STARTING_THREADS\" \"1\""
				java -cp "$1"/"$2" "$3" "$4" "$5" "$6" "$STARTING_THREADS" "1"
				elif [[ "$#" -eq 9 ]]; then
				echo "java -cp \"$1\"/\"$2\" \"$3\" \"$4\" \"$5\" \"$6\" \"$STARTING_THREADS\" \"1\" \"$9\""
				java -cp "$1"/"$2" "$3" "$4" "$5" "$6" "$STARTING_THREADS" "1" "$9"
				elif [[ "$#" -eq 10 ]]; then
				echo "java -cp \"$1\"/\"$2\" \"$3\" \"$4\" \"$5\" \"$6\" \"$STARTING_THREADS\" \"1\" \"$9\" \"${10}\""
				java -Xms4096m -Xmx8192m -cp "$1"/"$2" "$3" "$4" "$5" "$6" "$STARTING_THREADS" "1" "$9" "${10}"
				fi
				echo "Ended execution"
				# Linux
				echo 3 > '/proc/sys/vm/drop_caches'
				#swapoff -a
				#swapon -a
				# Mac OS
				purge
				# Windows
				C:/Windows/System32/rundll32.exe advapi32.dll,ProcessIdleTasks

				printf '\n%s\n' 'RAM-cache & Swap cleared'
				#sleep 120
			done;
			(( STARTING_THREADS=STARTING_THREADS+10 ))
		done

	fi
}

main "$@"

