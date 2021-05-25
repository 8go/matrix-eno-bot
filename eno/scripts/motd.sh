#!/bin/bash

if [ -f /etc/motd ]; then
	cat /etc/motd
else
	echo "There is no message of the day on your system. So, be happpy."
fi

# EOF
