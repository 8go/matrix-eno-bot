#!/bin/bash

# e.g. check os

if [ "$#" == "0" ]; then
	echo "You must be checking the health of something. Try \"check os\"."
        echo "\"bot\", \"matrix\", \"os\", \"services\", and \"world\" are configured on server."
	exit 0
fi
arg1=$1
case "${arg1,,}" in
"bot" | "eno" | "mybot")
	echo "The bot will check the health of itself."
	systemctl status matrix-eno-bot
	;;
"matrix")
	echo "The bot will check the health of matrix service."
	# the name of the service might vary based on installation from : synapse-matrix, matrix, etc.
	# let#s check all services that contain "matrix" in their name
	service --status-all | grep -i matrix | tr -s " " | cut -d " " -f 5 | while read -r p; do
		systemctl status "$p"
	done
	;;
"os")
	echo "The bot will check for possible updates for the operating system"
	type apt >/dev/null 2>&1 && type dnf >/dev/null 2>&1 && echo "Don't know how to check for updates as your system does neither support apt nor dnf." && exit 0
	# dnf OR apt exists
	type dnf >/dev/null 2>&1 || {
		apt list --upgradeable
		apt-get --just-print upgrade 2>/dev/null | grep -v "NOTE: This is only a simulation!" |
			grep -v "apt-get needs root privileges for real execution." |
			grep -v "Keep also in mind that locking is deactivated," |
			grep -v "so don't depend on the relevance to the real current situation!"
	}
	type apt >/dev/null 2>&1 || {
		dnf -q check-update
		dnf -q updateinfo
		dnf -q updateinfo list sec
	}
	;;
"services" | "service")
	service --status-all
	;;
"world")
	echo "The world definitely needs some upgrades!"
	;;
*)
	echo "This bot does not know how to check up on ${arg1}."
	echo "Only \"bot\", \"matrix\", \"os\", \"services\", and \"world\" are configured on server."
	;;
esac

# EOF
