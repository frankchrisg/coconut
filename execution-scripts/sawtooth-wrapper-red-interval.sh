#!/bin/bash

for j in 50 100 200 400; do for y in 1 50 100; do for i in {1..3}; do
if [ $y -eq 1 ]; then
for x in 1 2 5 10; do
bash start-abpes-sawtooth-x-all-30-red.sh "hetzner-repid-$i-sawtooth-rl-$j-notpbpc-$y-nobpc-1-maxbtperbl-100000-notppc-$y-cpbftbpd-$x" "$j" "$y" 1 100000 "$y" "$x";
done;
fi;

if [ $y -eq 50 ]; then
for x in 1 2 5 10; do
bash start-abpes-sawtooth-x-all-30-red.sh "hetzner-repid-$i-sawtooth-rl-$j-notpbpc-$y-nobpc-1-maxbtperbl-100000-notppc-$y-cpbftbpd-$x" "$j" "$y" 1 100000 "$y" "$x";
done;
fi;

if [ $y -eq 100 ]; then
for x in 1 2 5 10; do
bash start-abpes-sawtooth-x-all-30-red.sh "hetzner-repid-$i-sawtooth-rl-$j-notpbpc-$y-nobpc-1-maxbtperbl-100000-notppc-$y-cpbftbpd-$x" "$j" "$y" 1 100000 "$y" "$x";
done;
fi;

done; done; done;

#WRITE_PAYLOADS_PER_SECOND=$2
#NUMBER_OF_TRANSACTIONS_PER_BATCH_PER_CLIENT=$3
#NUMBER_OF_BATCHES_PER_CLIENT=$4
#PUBLISHER_MAX_BATCHES_PER_BLOCK=$5
#NUMBER_OF_TRANSACTION_PAYLOADS_PER_CLIENT=$6
#CONSENSUS_PBFT_BLOCK_PUBLISHING_DELAY=$7
