#!/bin/bash

src_dir=$1
limit=$2
dest_dir=$3

if [ ! -d $src_dir ]; then
    echo "Source directory $src_dir does not exist."
    exit 1
fi

if [ ! -d $dest_dir ]; then
    echo "Destination directory $dest_dir does not exist."
    mkdir -p "$dest_dir"
fi

count=0
for f in "$src_dir"/*
do
    if [ "$count" -ge "$limit" ]; then
        break
    fi
    mv "$f" "$dest_dir" && echo "Moved $f to $dest_dir"
    ((count++))
done

echo "$count items moved from $src_dir to $dest_dir"
