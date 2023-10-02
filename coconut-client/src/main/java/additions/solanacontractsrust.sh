#!/bin/bash

CONTRACT_PATH="/mnt/hgfs/E/ABPES_concurrent/src/main/java/solana/contracts"

files=(
  "bubbleSort.rs"
  "bubbleSortRec.rs"
  "doNothing.rs"
  "heapSort.rs"
  "heapSortPartlyRec.rs"
  "insertionSort.rs"
  "insertionSortRec.rs"
  "io.rs"
  "io_ex.rs"
  "keyvalue.rs"
  "keyvalue_ex.rs"
  "keyvalue_storage.rs"
  "keyvalue_ex_storage.rs"
  "loopc.rs"
  "memory.rs"
  "mergeSortBreadthFirst.rs"
  "mergeSortRec.rs"
  "quicksortPartlyIterative.rs"
  "quicksortRec.rs"
  "recursion.rs"
  "selectionSort.rs"
  "selectionSortRec.rs"
  "slowSort.rs"
  "smallbank.rs"
)

names=(
  "bubble_sort"
  "bubble_sort_rec"
  "do_nothing"
  "heap_sort"
  "heap_sort_partly_rec"
  "insertion_sort"
  "insertion_sort_rec"
  "io"
  "io_ex"
  "keyvalue"
  "keyvalue_ex"
  "keyvalue_storage"
  "keyvalue_ex_storage"
  "loopc"
  "memory"
  "merge_sort_breadth_first"
  "merge_sort_rec"
  "quick_sort_partly_iterative"
  "quick_sort_rec"
  "recursion"
  "selection_sort"
  "selection_sort_rec"
  "slow_sort"
  "small_bank"
)

array_length="${#files[@]}"
loopVarStart="$1"
loopVarEnd="$2"

cd $CONTRACT_PATH || exit
for ((i = loopVarStart; i <= loopVarEnd; i++)); do
  rm -rf "${names[i]}"
  cargo new --lib "${names[i]}"
  cp -rf tomltemplate "${names[i]}"/Cargo.toml
  sed -i "s/placeholder_name/${names[i]}/g" "${names[i]}"/Cargo.toml
  cp -rf "${files[i]}" "${names[i]}"/src/lib.rs
  cd "${names[i]}" || exit
  cargo build-bpf
  cd - &>/dev/null || exit
done
cd - &>/dev/null || exit
