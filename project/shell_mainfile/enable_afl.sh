#!/bin/bash

set -e

# sudo bash -c 'echo core > /proc/sys/kernel/core_pattern'
# cd /sys/devices/system/cpu
# sudo bash -c 'echo performance | tee cpu*/cpufreq/scaling_governor'

bash -c 'echo core > /proc/sys/kernel/core_pattern'
cd /sys/devices/system/cpu
bash -c 'echo performance | tee cpu*/cpufreq/scaling_governor'

pwd