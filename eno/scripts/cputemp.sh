#!/bin/bash

# single Core
# CELSIUS=$(cat /sys/class/thermal/thermal_zone0/temp) && echo "scale=2; $CELSIUS/1000" | bc | tr "\n" " " && echo "Celsius"

# multi-core CPU
cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | while read -r p; do
	# echo "$p"
	CELSIUS="$p" && echo "scale=2; $CELSIUS/1000" | bc | tr "\n" " " && echo "Celsius"
done
if [ "$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | wc -l)" == "0" ]; then
	echo "No CPU temperature information found."
fi
exit 0

# EOF
