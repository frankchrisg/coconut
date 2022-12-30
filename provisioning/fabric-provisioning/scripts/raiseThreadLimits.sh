#!/bin/bash
# Just a simple script to raise thread limits, adjust values as needed.

echo 250000 | sudo tee /sys/fs/cgroup/pids/user.slice/user-1000.slice/pids.max
echo 250000 | sudo tee /proc/sys/kernel/pid_max
echo 250000 | sudo tee /proc/sys/vm/max_map_count
echo 250000 | sudo tee /proc/sys/kernel/threads-max
ulimit -s 25000
#ulimit -i
