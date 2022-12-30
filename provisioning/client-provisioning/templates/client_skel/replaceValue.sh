#!/bin/bash

replaceConfigurationValues() {

  DELIMITER_LINE=$1
  DELIMITER_VARIABLE=$2
  OUTPUT_ADJUSTED_FILE=$3
  FINAL_CONFIGURATION_FILE=$4
  key=$5
  value=$6

  echo "Key: $key"
	
	PREFIX='cst_sh '
	if [[ "$value" =~ ^"$PREFIX" ]]; then
	value=$(echo "$value" | grep -oP "^$PREFIX\K.*")
	value=$(eval "$value")
	echo "New value: $value"
	fi
	
    echo "Value: $value"

    declare -A arr
    arr["$key"]="$value"

  for variable in "${!arr[@]}"; do
    sed -i "s${DELIMITER_VARIABLE}\($variable*${DELIMITER_LINE}*\)\(.*\)${DELIMITER_VARIABLE}\1${arr[$variable]}${DELIMITER_VARIABLE}g" "$OUTPUT_ADJUSTED_FILE"
  done

  cp "$OUTPUT_ADJUSTED_FILE" "$FINAL_CONFIGURATION_FILE"

  echo "Created $FINAL_CONFIGURATION_FILE"

}

replaceConfigurationValues "$1" "$2" "$3" "$4" "$5" "$6"

