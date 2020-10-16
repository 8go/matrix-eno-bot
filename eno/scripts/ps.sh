#!/bin/bash

free -m | awk 'NR==2{printf "Memory Usage: %s/%sMB (%.2f %%)\n", $3,$2,$3*100/$2 }'
df -h | awk '$NF=="/"{printf "Disk Usage: %d/%dGB (%s)\n", $3,$2,$5}'
# top -bn1 | grep load | awk '{printf "CPU Load: %.2f\n", $(NF-2)}'
CPU=$(top -bn1 | head -n 1 | cut -d "," -f 5 | tr -d " ")  # last 5 min CPU load average as "0.03" for 3%
CPUP=$(LC_ALL=en_US.UTF-8 printf "%'.0f" "$(echo "scale=10; $CPU * 100.0" | bc -l)")
echo "CPU Load: $CPUP %"
echo -n "CPU Temperature: " 
# assume 'ps.sh' and 'cputemp.sh' are in same directory
#$(dirname "${0}")/cputemp.sh

# assume cputemp.sh is in PATH
cputemp.sh

# EOF
