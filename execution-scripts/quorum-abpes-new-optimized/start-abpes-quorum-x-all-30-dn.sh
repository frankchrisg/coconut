#!/bin/bash

BLOCKCHAIN_BASEPATH="/home/parallels/quorum-new-final"

inputBlockchain="$BLOCKCHAIN_BASEPATH/commonPlaybookQuorum.txt,$BLOCKCHAIN_BASEPATH/EMPTY_FILE.txt"

configurationBlockchain="$BLOCKCHAIN_BASEPATH/common-playbook-quorum.yaml,$BLOCKCHAIN_BASEPATH/hosts-quorum-4.txt"

destinationBlockchain="/home/parallels/FINAL_graphene_corda_latest_xxx/quorum-provisioning/vars/common-vars.yaml,\
/home/parallels/FINAL_graphene_corda_latest_xxx/quorum-provisioning/hosts"

inputClient="$BLOCKCHAIN_BASEPATH/donothing/generalConfiguration-donothing-doNothing-40.txt,$BLOCKCHAIN_BASEPATH/donothing/quorumConfiguration-donothing-doNothing-40.txt"

configurationClient="$BLOCKCHAIN_BASEPATH/generalConfiguration.properties,$BLOCKCHAIN_BASEPATH/quorumConfiguration.properties"

destinationClient="/home/parallels/FINAL_graphene_corda_latest_xxx/client/templates/client_skel/configs/generalConfiguration.properties,/home/parallels/FINAL_graphene_corda_latest_xxx/client/templates/client_skel/configs/quorumConfiguration.properties"

inputClientProv="$BLOCKCHAIN_BASEPATH/clientCommonPlaybookCommonquorum.txt,$BLOCKCHAIN_BASEPATH/clientPlaybookquorum.txt"

configurationClientProv="$BLOCKCHAIN_BASEPATH/client-common-playbook-vars.yaml,$BLOCKCHAIN_BASEPATH/client-playbook-vars.yaml"

destinationClientProv="/home/parallels/FINAL_graphene_corda_latest_xxx/client/vars/common-vars.yaml,/home/parallels/FINAL_graphene_corda_latest_xxx/client/vars/client-vars.yaml"

workingDirBlockchain="/home/parallels/FINAL_graphene_corda_latest_xxx/quorum-provisioning"

workingDirClient="/home/parallels/FINAL_graphene_corda_latest_xxx/client"

backupFilesAndDirectories=(vars/ hosts ansible.cfg)
backupFilesAndDirectoriesClient=(vars/ hosts ansible.cfg)

backupPath="/home/parallels/Desktop/backups-abpes"
backupPathClient="/home/parallels/Desktop/backups-abpes-client"

RUN_ID_SUFFIX=$1
WRITE_PAYLOADS_PER_SECOND=$2
ISTANBUL_BLOCKPERIOD=$3

containsElement() {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

GLOBAL_COUNTER_BS=0
GLOBAL_COUNTER_CLIENT=0
#GLOBAL_COUNTER_BMS=("DoNothing" "KeyValue-Set" "KeyValue-Get" "BankingApp CreateAccount" "BankingApp SendPayment" "BankingApp Balance")
#ISTANBUL_BLOCKPERIOD_ARR=(1 5 5 5 5 5)
#RATE_LIMITER_ARR=(200 100 100 100 400 100)
GLOBAL_COUNTER_BMS=("DoNothing")
ISTANBUL_BLOCKPERIOD_ARR=(1)
RATE_LIMITER_ARR=(200)

handleCurrentBmBs() {

echo ${GLOBAL_COUNTER_BMS[$GLOBAL_COUNTER_BS]}

GLOBAL_COUNTER_BS=$(( GLOBAL_COUNTER_BS + 1))

if [ $GLOBAL_COUNTER_BS -gt 6 ]
then
GLOBAL_COUNTER_BS=0
echo "Reset"
elif [ $GLOBAL_COUNTER_BS -eq 1 ]
then
ISTANBUL_BLOCKPERIOD=${ISTANBUL_BLOCKPERIOD_ARR[0]}
elif [ $GLOBAL_COUNTER_BS -eq 2 ]
then
ISTANBUL_BLOCKPERIOD=${ISTANBUL_BLOCKPERIOD_ARR[1]}
elif [ $GLOBAL_COUNTER_BS -eq 3 ]
then
ISTANBUL_BLOCKPERIOD=${ISTANBUL_BLOCKPERIOD_ARR[2]}
elif [ $GLOBAL_COUNTER_BS -eq 4 ]
then
ISTANBUL_BLOCKPERIOD=${ISTANBUL_BLOCKPERIOD_ARR[3]}
elif [ $GLOBAL_COUNTER_BS -eq 5 ]
then
ISTANBUL_BLOCKPERIOD=${ISTANBUL_BLOCKPERIOD_ARR[4]}
elif [ $GLOBAL_COUNTER_BS -eq 6 ]
then
ISTANBUL_BLOCKPERIOD=${ISTANBUL_BLOCKPERIOD_ARR[5]}
fi
echo "$ISTANBUL_BLOCKPERIOD $GLOBAL_COUNTER_BS ${GLOBAL_COUNTER_BMS[$GLOBAL_COUNTER_BS-1]}" >> ~/quorum-opti.txt
}

handleCurrentBmClient() {

echo ${GLOBAL_COUNTER_BMS[$GLOBAL_COUNTER_CLIENT]}

GLOBAL_COUNTER_CLIENT=$(( GLOBAL_COUNTER_CLIENT + 1))

if [ $GLOBAL_COUNTER_CLIENT -gt 6 ]
then
GLOBAL_COUNTER_CLIENT=0
echo "Reset"
elif [ $GLOBAL_COUNTER_CLIENT -eq 1 ]
then
WRITE_PAYLOADS_PER_SECOND=${RATE_LIMITER_ARR[0]}
elif [ $GLOBAL_COUNTER_CLIENT -eq 2 ]
then
WRITE_PAYLOADS_PER_SECOND=${RATE_LIMITER_ARR[1]}
elif [ $GLOBAL_COUNTER_CLIENT -eq 3 ]
then
WRITE_PAYLOADS_PER_SECOND=${RATE_LIMITER_ARR[2]}
elif [ $GLOBAL_COUNTER_CLIENT -eq 4 ]
then
WRITE_PAYLOADS_PER_SECOND=${RATE_LIMITER_ARR[3]}
elif [ $GLOBAL_COUNTER_CLIENT -eq 5 ]
then
WRITE_PAYLOADS_PER_SECOND=${RATE_LIMITER_ARR[4]}
elif [ $GLOBAL_COUNTER_CLIENT -eq 6 ]
then
WRITE_PAYLOADS_PER_SECOND=${RATE_LIMITER_ARR[5]}
fi
echo "$WRITE_PAYLOADS_PER_SECOND $GLOBAL_COUNTER_CLIENT ${GLOBAL_COUNTER_BMS[$GLOBAL_COUNTER_CLIENT-1]}" >> ~/quorum-opti.txt
}

replaceConfigurationValues() {

  DELIMITER_LINE=$1
  DELIMITER_VARIABLE=$2
  INPUT_REPLACEMENT_FILE=$3
  OUTPUT_ADJUSTED_FILE=$4
  FINAL_CONFIGURATION_FILE=$5
  DATE_SUFFIX=$6
  IS_SUFFIX_TO_REPLACE=$7

  mkdir -p "$backupPath"/"$dateSuffix"
  cp -rf "$OUTPUT_ADJUSTED_FILE" "$backupPath"/"$dateSuffix"/"$(basename "$OUTPUT_ADJUSTED_FILE""$DEFAULT_FILE_ENDING")"

  while IFS= read -r line; do

    key=$(echo "$line" | awk -v prm="$DELIMITER_LINE" '{split($0,a,prm); print a[1]}')
    #valueForKey=$(echo "$line" | awk -v prm="$DELIMITER_LINE" '{split($0,a,prm); print a[2]}')
    valueForKey=$(echo "$line" | awk -v prm="$DELIMITER_LINE" -F "$DELIMITER_LINE" '{st=index($0,prm);print substr($0,st+1)}' | sed 's/^ *//g')

    echo "Key: $key"
    echo "Line: $line"

    if [[ "$key" =~ ^"#" ]]; then
      echo "Comment found for: $line, not processing"
      continue
    fi

    PREFIX='cst_sh '
    if [[ "$valueForKey" =~ ^"$PREFIX" ]]; then
      valueForKey=$(echo "$valueForKey" | grep -oP "^$PREFIX\K.*")
      valueForKey=$(eval "$valueForKey")
      echo "New valueForKey: $valueForKey"
    fi

    if [ "$key" == "RUN_ID" ] && [ "$IS_SUFFIX_TO_REPLACE" == "true" ]; then
      newValueForKey=$(echo "${valueForKey}-${RUN_ID_SUFFIX}" | tr -d '\r' | tr -d '\n')
      valueForKey="$newValueForKey"
      echo "New RUN_ID set to: $valueForKey"
    fi

    echo "valueForKey: $valueForKey"

    declare -A arr
    arr["$key"]="$valueForKey"

  done <"$INPUT_REPLACEMENT_FILE"

  for variable in "${!arr[@]}"; do
    #    sed -i "s${DELIMITER_VARIABLE}\($variable*${DELIMITER_LINE}*\)\(.*\)${DELIMITER_VARIABLE}\1${arr[$variable]}${DELIMITER_VARIABLE}g" "$OUTPUT_ADJUSTED_FILE"
    #    sed -i "s${DELIMITER_VARIABLE}\(^$variable${DELIMITER_LINE}*\)\(.*\)${DELIMITER_VARIABLE}\1${arr[$variable]}${DELIMITER_VARIABLE}g" "$OUTPUT_ADJUSTED_FILE"
    sed -i "s${DELIMITER_VARIABLE}\(^$variable${DELIMITER_LINE}\)\(.*\)${DELIMITER_VARIABLE}\1${arr[$variable]}${DELIMITER_VARIABLE}g" "$OUTPUT_ADJUSTED_FILE"
  done

  echo "Output adjusted file: $OUTPUT_ADJUSTED_FILE final configuration file: $FINAL_CONFIGURATION_FILE"
  cp -rf "$OUTPUT_ADJUSTED_FILE" "$FINAL_CONFIGURATION_FILE"
  echo "Created $FINAL_CONFIGURATION_FILE"

}

iterateOverBlockchainConfigurationFiles() {

  DEFAULT_DELIMITER_LINE=": "
  DEFAULT_DELIMITER_VARIABLE="?"
  DEFAULT_FILE_ENDING=".txt"

  CONCAT_STRING="$1"
  DATE_SUFFIX="$2"

  inputBlockchainParam="$(echo "$CONCAT_STRING" | awk -v prm="?" '{split($0,a,prm); print a[1]}')"
  configurationBlockchainParam="$(echo "$CONCAT_STRING" | awk -v prm="?" '{split($0,a,prm); print a[2]}')"
  destinationBlockchainParam="$(echo "$CONCAT_STRING" | awk -v prm="?" '{split($0,a,prm); print a[3]}')"

  readarray -td "," inputBlockchainArr < <(printf '%s' "$inputBlockchainParam")
  declare -p inputBlockchainArr
  readarray -td "," configurationBlockchainArr < <(printf '%s' "$configurationBlockchainParam")
  declare -p configurationBlockchainArr
  readarray -td "," destinationBlockchainArr < <(printf '%s' "$destinationBlockchainParam")
  declare -p destinationBlockchainArr

  if [ ! "${#inputBlockchainArr[@]}" -eq "${#configurationBlockchainArr[@]}" ] || [ ! "${#inputBlockchainArr[@]}" -eq "${#destinationBlockchainArr[@]}" ]; then
    echo "Unequal number of files to modify and create"
    exit 0
  fi

  for value in "${!inputBlockchainArr[@]}"; do
    replaceConfigurationValues "$DEFAULT_DELIMITER_LINE" "$DEFAULT_DELIMITER_VARIABLE" "${inputBlockchainArr[value]}" "${configurationBlockchainArr[value]}" "${destinationBlockchainArr[value]}" "$DATE_SUFFIX" "false"

	if [ -z ${ISTANBUL_BLOCKPERIOD} ];
    then
        echo "Not replacing istanbul blockperiod..."
    else
        sed -i "s/ISTANBUL_BLOCKPERIOD: .*/ISTANBUL_BLOCKPERIOD: ${ISTANBUL_BLOCKPERIOD}/g" "${destinationBlockchainArr[value]}"
    fi

  done

}

iterateOverClientConfigurationFiles() {

  DEFAULT_DELIMITER_LINE="="
  DEFAULT_DELIMITER_VARIABLE="?"
  DEFAULT_FILE_ENDING=".txt"

  CONCAT_STRING="$1"
  DATE_SUFFIX="$2"

  inputClientParam="$(echo "$CONCAT_STRING" | awk -v prm="?" '{split($0,a,prm); print a[1]}')"
  configurationClientParam="$(echo "$CONCAT_STRING" | awk -v prm="?" '{split($0,a,prm); print a[2]}')"
  destinationClientParam="$(echo "$CONCAT_STRING" | awk -v prm="?" '{split($0,a,prm); print a[3]}')"

  readarray -td "," inputClientArr < <(printf '%s' "$inputClientParam")
  declare -p inputClientArr
  readarray -td "," configurationClientArr < <(printf '%s' "$configurationClientParam")
  declare -p configurationClientArr
  readarray -td "," destinationClientArr < <(printf '%s' "$destinationClientParam")
  declare -p destinationClientArr

  if [ ! "${#inputClientArr[@]}" -eq "${#configurationClientArr[@]}" ] || [ ! "${#inputClientArr[@]}" -eq "${#destinationClientArr[@]}" ]; then
    echo "Unequal number of files to modify and create"
    exit 0
  fi

handleCurrentBmClient

  for value in "${!inputClientArr[@]}"; do
    replaceConfigurationValues "$DEFAULT_DELIMITER_LINE" "$DEFAULT_DELIMITER_VARIABLE" "${inputClientArr[value]}" "${configurationClientArr[value]}" "${destinationClientArr[value]}" "$DATE_SUFFIX" "true"

	if [ -z ${WRITE_PAYLOADS_PER_SECOND} ];
    then
        echo "Not replacing write payloads per second..."
    else
        sed -i "s/WRITE_PAYLOADS_PER_SECOND=.*/WRITE_PAYLOADS_PER_SECOND=${WRITE_PAYLOADS_PER_SECOND}/g" "${destinationClientArr[value]}"
        sed -i "s/ENABLE_RATE_LIMITER_FOR_WRITE_PAYLOADS=.*/ENABLE_RATE_LIMITER_FOR_WRITE_PAYLOADS=true/g" "${destinationClientArr[value]}"
		sed -i "s/LISTENER_THRESHOLD=.*/LISTENER_THRESHOLD=-1.0/g" "${destinationClientArr[value]}"
		sed -i "s/LISTENER_TOTAL_THRESHOLD=.*/LISTENER_TOTAL_THRESHOLD=-1.0/g" "${destinationClientArr[value]}"
    fi

  done

}

TOTAL_RUNS=1
BLOCKCHAIN_RUNS=1
TOTAL_CLIENT_RUNS=1
CLIENT_RUNS=1

RAMPUP_TIME_BLOCKCHAIN_BEFORE_RUNS=1s
RAMPUP_TIME_BLOCKCHAIN_RUNS=1s
RAMPUP_TIME_CLIENT_BEFORE_RUNS=180s
RAMPUP_TIME_CLIENT_RUNS=1s

FORKS_CLIENT=1000
FORKS_BLOCKCHAIN=10

SEPARATE_RUNS=()
#(2 3 4 5 7 10)
SEPARATE_RUNS_NUMBER=0
SKIPPING_RUNS_CLIENT=()
#(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16)

execClient() {

  for k in $(seq 1 "$TOTAL_CLIENT_RUNS"); do
    readarray -td "|" inputClientArray < <(printf '%s' "$inputClient")
    declare -p inputClientArray
    readarray -td "|" configurationClientArray < <(printf '%s' "$configurationClient")
    declare -p configurationClientArray
    readarray -td "|" destinationClientArray < <(printf '%s' "$destinationClient")
    declare -p destinationClientArray

    x=0
    SEPARATE_RUNS_NUMBER=0

    for value in "${!inputClientArray[@]}"; do

      prepareClient "$x"
      #x=$((x+1))
      ((x = x + 1))

      CONCAT_STRING="${inputClientArray[value]}?${configurationClientArray[value]}?${destinationClientArray[value]}"
      dateSuffix=$(date | tr -d " ")

      iterateOverClientConfigurationFiles "$CONCAT_STRING" "$dateSuffix"

      ((SEPARATE_RUNS_NUMBER = SEPARATE_RUNS_NUMBER + 1))

if [ "$SEPARATE_RUNS_NUMBER" -gt 1 ]; then
handleCurrentBmBs
sed -i "s/ISTANBUL_BLOCKPERIOD: .*/ISTANBUL_BLOCKPERIOD: ${ISTANBUL_BLOCKPERIOD}/g" "/home/parallels/FINAL_graphene_corda_latest_xxx/quorum-provisioning/vars/common-vars.yaml"
fi

      if containsElement "$SEPARATE_RUNS_NUMBER" "${SKIPPING_RUNS_CLIENT[@]}" -eq 0; then
        echo "Skipping run: $SEPARATE_RUNS_NUMBER"
        continue
      fi

      if [ ${#SEPARATE_RUNS[@]} -gt 0 ] && [ "$SEPARATE_RUNS_NUMBER" -eq "${SEPARATE_RUNS[0]}" ]; then
        echo "Re-provisioning triggered"
        SEPARATE_RUNS=("${SEPARATE_RUNS[@]:1}")
        cd $workingDirBlockchain || exit
        $(which ansible-playbook) -vv runlocal.yaml --forks $FORKS_BLOCKCHAIN --tags "bm-run,bm-rem,bm-set"
      fi

      sleep $RAMPUP_TIME_CLIENT_BEFORE_RUNS
      for l in $(seq 1 "$CLIENT_RUNS"); do
        sleep $RAMPUP_TIME_CLIENT_RUNS

        cd $workingDirClient || exit
        $(which ansible-playbook) runlocal.yaml --forks $FORKS_CLIENT --tags "bm-run,bm-rem,bm-set"
      done
    done
  done

}

prepareClient() {

  readarray -td "|" inputClientProvArray < <(printf '%s' "$inputClientProv")
  declare -p inputClientProvArray
  readarray -td "|" configurationClientProvArray < <(printf '%s' "$configurationClientProv")
  declare -p configurationClientProvArray
  readarray -td "|" destinationClientProvArray < <(printf '%s' "$destinationClientProv")
  declare -p destinationClientProvArray

  if [ ! "${#inputClientArray[@]}" -eq "${#inputClientProvArray[@]}" ] || [ ! "${#configurationClientArray[@]}" -eq "${#configurationClientProvArray[@]}" ] || [ ! "${#destinationClientArray[@]}" -eq "${#destinationClientProvArray[@]}" ]; then
    echo "Unequal number of files for client runs"
    exit 0
  fi

  #  for valuePrepareClient in "${!inputClientProvArray[@]}"; do
  valuePrepareClient="$1"
  #valuePrepareClient="${inputClientProvArray[iCounter]}"
  dateSuffix=$(date | tr -d " ")
  CONCAT_STRING="${inputClientProvArray[valuePrepareClient]}?${configurationClientProvArray[valuePrepareClient]}?${destinationClientProvArray[valuePrepareClient]}"
  iterateOverClientProvConfigurationFiles "$CONCAT_STRING" "$dateSuffix"

  mkdir -p "$backupPathClient"/"$dateSuffix"
  for item in "${backupFilesAndDirectoriesClient[@]}"; do
    dateSuffix=$(date | tr -d " ")
    cp -rf "$workingDirClient"/"$item" "$backupPathClient"/"$dateSuffix"/
  done
  #  done

}

iterateOverClientProvConfigurationFiles() {

  DEFAULT_DELIMITER_LINE=": "
  DEFAULT_DELIMITER_VARIABLE="?"
  DEFAULT_FILE_ENDING=".txt"

  CONCAT_STRING="$1"
  DATE_SUFFIX="$2"

  inputClientProvParam="$(echo "$CONCAT_STRING" | awk -v prm="?" '{split($0,a,prm); print a[1]}')"
  configurationClientProvParam="$(echo "$CONCAT_STRING" | awk -v prm="?" '{split($0,a,prm); print a[2]}')"
  destinationClientProvParam="$(echo "$CONCAT_STRING" | awk -v prm="?" '{split($0,a,prm); print a[3]}')"

  readarray -td "," inputClientProvArr < <(printf '%s' "$inputClientProvParam")
  declare -p inputClientProvArr
  readarray -td "," configurationClientProvArr < <(printf '%s' "$configurationClientProvParam")
  declare -p configurationClientProvArr
  readarray -td "," destinationClientProvArr < <(printf '%s' "$destinationClientProvParam")
  declare -p destinationClientProvArr

  if [ ! "${#inputClientProvArr[@]}" -eq "${#configurationClientProvArr[@]}" ] || [ ! "${#inputClientProvArr[@]}" -eq "${#destinationClientProvArr[@]}" ]; then
    echo "Unequal number of files to modify and create"
    exit 0
  fi

  for valuePrepareClient in "${!inputClientProvArr[@]}"; do
    replaceConfigurationValues "$DEFAULT_DELIMITER_LINE" "$DEFAULT_DELIMITER_VARIABLE" "${inputClientProvArr[valuePrepareClient]}" "${configurationClientProvArr[valuePrepareClient]}" "${destinationClientProvArr[valuePrepareClient]}" "$DATE_SUFFIX" "false"
  done

}

execBlockchain() {

  for i in $(seq 1 $TOTAL_RUNS); do
    readarray -td "|" inputBlockchainArray < <(printf '%s' "$inputBlockchain")
    declare -p inputBlockchainArray
    readarray -td "|" configurationBlockchainArray < <(printf '%s' "$configurationBlockchain")
    declare -p configurationBlockchainArray
    readarray -td "|" destinationBlockchainArray < <(printf '%s' "$destinationBlockchain")
    declare -p destinationBlockchainArray
    for value in "${!inputBlockchainArray[@]}"; do
      dateSuffix=$(date | tr -d " ")
      CONCAT_STRING="${inputBlockchainArray[value]}?${configurationBlockchainArray[value]}?${destinationBlockchainArray[value]}"
      iterateOverBlockchainConfigurationFiles "$CONCAT_STRING" "$dateSuffix"
      sleep $RAMPUP_TIME_BLOCKCHAIN_BEFORE_RUNS
      for j in $(seq 1 $BLOCKCHAIN_RUNS); do
handleCurrentBmBs
sed -i "s/ISTANBUL_BLOCKPERIOD: .*/ISTANBUL_BLOCKPERIOD: ${ISTANBUL_BLOCKPERIOD}/g" "/home/parallels/FINAL_graphene_corda_latest_xxx/quorum-provisioning/vars/common-vars.yaml"
        sleep $RAMPUP_TIME_BLOCKCHAIN_RUNS
        cd $workingDirBlockchain || exit
        $(which ansible-playbook) -vv runlocal.yaml --forks $FORKS_BLOCKCHAIN --tags "bm-run,bm-rem,bm-set"

        mkdir -p "$backupPath"/"$dateSuffix"
        for item in "${backupFilesAndDirectories[@]}"; do
          dateSuffix=$(date | tr -d " ")
          cp -rf "$workingDirBlockchain"/"$item" "$backupPath"/"$dateSuffix"/
        done

        execClient
      done
    done
  done

}

#execClient
execBlockchain
