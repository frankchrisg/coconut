#!/bin/bash

A="client-10000000-0-0-24-0-0-119999 serverip=0.0.0.0 cpu_cores=0-7"
B="client-20000000-1-25-49-1-120000-239999 serverip=0.0.0.0 cpu_cores=0-7"
C="client-30000000-2-50-74-2-240000-359999 serverip=0.0.0.0 cpu_cores=8-15"
D="client-40000000-3-75-99-3-360000-479999 serverip=0.0.0.0 cpu_cores=8-15"

HOST_PATH="/home/parallels/FINAL_graphene_corda_latest_xxx/client/hosts"

RUNTIME=300; for x in 1; do for y in 1; do for i in {1..3}; do PREPARED_ACCOUNTS=60000;
#RUNTIME=300; for x in 50 100 200 400; do for y in 100 500 1000 2000; do for i in {1..3}; do PREPARED_ACCOUNTS=$((RUNTIME*x*4));
#RUNTIME=300; for x in 50; do for y in 100 500 1000 2000; do for i in {1..3}; do PREPARED_ACCOUNTS=$((RUNTIME*x*4));

l="";
m="";
n="";
o="";

cp -f $HOST_PATH ${HOST_PATH}_bakcl

for p in {1..4}; do
tr="$((((PREPARED_ACCOUNTS/4)*(p-1))))-$((((PREPARED_ACCOUNTS/4)*p)-1))";
#if [ "$p" == 1 ]; then l=$( echo "$A" | $(which sed) "s/0-119999/$tr/"); fi
#if [ "$p" == 2 ]; then m=$( echo "$B" | $(which sed) "s/120000-239999/$tr/"); fi
#if [ "$p" == 3 ]; then n=$( echo "$C" | $(which sed) "s/240000-359999/$tr/"); fi
#if [ "$p" == 4 ]; then o=$( echo "$D" | $(which sed) "s/360000-479999/$tr/"); fi

if [ "$p" == 1 ]; then l=$($(which sed) -i "s/0-119999/$tr/" "$HOST_PATH"); fi
if [ "$p" == 2 ]; then m=$($(which sed) -i "s/120000-239999/$tr/" "$HOST_PATH"); fi
if [ "$p" == 3 ]; then n=$($(which sed) -i "s/240000-359999/$tr/" "$HOST_PATH"); fi
if [ "$p" == 4 ]; then o=$($(which sed) -i "s/360000-479999/$tr/" "$HOST_PATH"); fi

done;

bash start-abpes-diem-x-all-30-red-optimized.sh "final8peers-repid-$i-diem-rl-opti-bs-opti-ppa-60000" "" "" "$PREPARED_ACCOUNTS";
#start-abpes-diem-x-all-30-red.sh "hetzner-repid-$i-diem-rl-$x-bs-$y-ppa-$PREPARED_ACCOUNTS" "$x" "$y" "$PREPARED_ACCOUNTS";

cp -f ${HOST_PATH}_bakcl $HOST_PATH

done; done; done;

#echo -e "$l\n$m\n$n\n$o"
