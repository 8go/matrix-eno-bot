#!/bin/bash

MEM_ALERT=0.8  # more than 80% of RAM used
CPU_ALERT=0.8  # more than 80% of CPU used, remember if there are 2 cores, this can go to 200%, 4 core to 400%
DSK_ALERT=0.9 # more than 80% of DISK used
TMP_ALERT=69  # 69C, temperature alert if above x C Celsius

# free -m | awk 'NR==2{printf "Memory Usage: %s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }'
# df -h | awk '$NF=="/"{printf "Disk Usage: %d/%dGB (%s)\n", $3,$2,$5}'
# top -bn1 | grep load | awk '{printf "CPU Load: %.2f\n", $(NF-2)}'

# Memory Usage: 536/3793MB (14.13%)
# Disk Usage: 7/30GB (25%)
# CPU Load: 0.22

MEM=$(free -m | awk 'NR==2{printf "%.2f", $3/$2 }') # total mem/used mem (does not look at swap)
CPU=$(top -bn1 | head -n 1 | cut -d "," -f 5 | tr -d " ")  # last 5 min CPU load average as "0.03" for 3%
DSKP=$(df -h | awk '$NF=="/"{printf substr($5, 1, length($5)-1)}')                   # e.g. 25 for 25%
DSK=$(LC_ALL=en_US.UTF-8 printf "%'.2f" "$(echo "scale=10; $DSKP / 100.0" | bc -l)") # e.g. 0.25

MEMP=$(LC_ALL=en_US.UTF-8 printf "%'.0f" "$(echo "scale=10; $MEM * 100.0" | bc -l)")
CPUP=$(LC_ALL=en_US.UTF-8 printf "%'.0f" "$(echo "scale=10; $CPU * 100.0" | bc -l)")

CELSIUS=$(cat /sys/class/thermal/thermal_zone0/temp)
TMP=$(echo "scale=0; $CELSIUS/1000" | bc | tr -d "\n")

# echo "MEM=$MEM, CPU=$CPU, DSK=$DSK, TEMP=$TMP"
# echo "MEM=${MEMP}%, CPU=${CPUP}%, DSK=${DSKP}%, TEMP=${TMP}C"

RET=0
MEM_STR=""
CPU_STR=""
DSK_STR=""
TMP_STR=""

if (($(echo "$MEM > $MEM_ALERT" | bc -l))); then
	MEM_STR="***$(date +%F\ %R)*** ALERT: memory consumption too high!\n"
	RET=$((RET + 1))
fi
if (($(echo "$CPU > $CPU_ALERT" | bc -l))); then
	CPU_STR="***$(date +%F\ %R)*** ALERT: CPU usage too high!\n"
	RET=$((RET + 2))
fi
if (($(echo "$DSK > $DSK_ALERT" | bc -l))); then
	DSK_STR="***$(date +%F\ %R)*** ALERT: disk too full!\n"
	RET=$((RET + 4))
fi
if (($(echo "$TMP > $TMP_ALERT" | bc -l))); then
	TMP_STR="***$(date +%F\ %R)*** ALERT: CPU temperature too high!\n"
	RET=$((RET + 8))
fi

if [ "$RET" != "0" ]; then
	echo "***$(date +%F\ %R)*** ### ALERT ### ALERT ### ALERT ###" >&2 # write this to stderr
	echo -e "${MEM_STR}${CPU_STR}${DSK_STR}${TMP_STR}MEM=${MEMP}%, CPU=${CPUP}%, DSK=${DSKP}%, TEMP=${TMP}C\n"
	# if there is an alert, also print the top 5 processes, see "top" script, code taken from there
	echo "Top 5 CPU consumers:"
	#ps -eo %cpu,pid,ppid,cmd --sort=-%cpu | head
	ps -eo %cpu,cmd --sort=-%cpu --cols 40 | head -n 5
	echo ""
	echo "Top 5 RAM consumers:"
	#ps -eo %mem,pid,ppid,cmd --sort=-%mem | head
	ps -eo %mem,cmd --sort=-%mem --cols 40 | head -n 5
fi

exit 0

# EOF
