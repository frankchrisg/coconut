#!/bin/bash

base_directory="$1"
target_directory_name="$2"
target_dir="/home/parallels/FINAL_graphene_corda_latest_xxx/teku/val$target_directory_name"

mkdir "$target_dir"

find "$base_directory" -mindepth 1 -type d | while read -r directory; do
    dir_name=$(basename "$directory")
    
    json_filename="${dir_name}.json"
    txt_filename="${dir_name}.txt"
    
    keystore_file="${directory}/voting-keystore.json"
    
    if [ -f "$keystore_file" ]; then
        cp "$keystore_file" "$target_dir/$json_filename"
        echo "Copied to $json_filename"
        
        echo "222222222222222222222222222222222222222222222222222" > "$target_dir/$txt_filename"
        echo "Created $txt_filename"
    else
        echo "voting-keystore.json not found in $directory"
    fi
done
