#!/bin/bash

TORIFY="torify"

# tor and torify should be installed for your privacy.
type torify >/dev/null 2>&1 || {
	echo "It is recommended that you install the packge \"tor\" on the server for privacy."
	TORIFY=""
}

# w3m must be installed
type w3m >/dev/null 2>&1 || {
	echo "This script requires that you install the packge \"w3m\" on the server."
	exit 0
}

if [ "$#" == "0" ]; then
	echo "You must be browsing some URL. Try \"web news.ycombinator.com\"."
	# echo "If torify is available all traffic will go through TOR by default."
	# echo "If you really must skip TOR, try \"web notorify news.ycombinator.com\"."
	exit 0
fi

if [ "$1" == "notorify" ]; then
	TORIFY=""
	shift # skip $1
fi

# if $1 is a number we must skip it, w3m will try to open port
# when calling w3m just give it 1 argument
case $1 in
    ''|*[!0-9]*) $TORIFY w3m -dump "$1" ;;
    *) echo "Not a valid URL" ;;
esac

# EOF
