#!/bin/bash

for i in {1..3}; do bash start-abpes-quorum-x-all-30-dn.sh "final8peers-hetzner-repid-$i-quorum-rl-opti-ib-opti"; done;
for i in {1..3}; do bash start-abpes-quorum-x-all-30-kv.sh "final8peers-hetzner-repid-$i-quorum-rl-opti-ib-opti"; done;
for i in {1..3}; do bash start-abpes-quorum-x-all-30-sb-red.sh "final8peers-hetzner-repid-$i-quorum-rl-opti-ib-opti"; done;

#for i in {1..3}; do bash start-abpes-quorum-x-all-30-dn.sh "eighthfinalnewlatencyhetzner-repid-$i-quorum-rl-opti-ib-opti"; done;
#for i in {1..3}; do bash start-abpes-quorum-x-all-30-kv.sh "eighthfinalnewlatencyhetzner-repid-$i-quorum-rl-opti-ib-opti"; done;
#for i in {1..3}; do bash start-abpes-quorum-x-all-30-sb-red.sh "eighthfinalnewlatencyhetzner-repid-$i-quorum-rl-opti-ib-opti"; done;
