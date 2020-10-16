#!/bin/bash

TORIFY="torify"

# tor and torify should be installed for your privacy.
type torify >/dev/null 2>&1 || {
	echo "It is recommended that you install the packge \"tor\" on the server for privacy."
	TORIFY=""
}

# rsstail must be installed
type rsstail >/dev/null 2>&1 || {
	echo "This script requires that you install the packge \"rsstail\" on the server."
	exit 0
}

function readrss() {
	feeddata=$($TORIFY rsstail -1 -ldpazPH -u "$1" -n "$2" 2>&1)
	if [ "$(echo "$feeddata" | xargs)" == "" ] ||
		[ "$feeddata" == "Error reading RSS feed: Parser error" ]; then
		echo "Can't screenscrape Twitter right now. Rate limits are in place. Come back later. ($1)"
		return 1
	fi
	echo "Fetching latest $2 items from feed \"$1\"..."
	# If there are 3 newlines, it will generate separate posts,
	# but it is nicer and more compact if everything is nicely bundled into 1 post.
	# So, first we use sed to remove all occurances of 5, 4, and 3 newlines.
	# Then we insert 2 newlines after the last newline to create 3 newlines,
	# so that at the end of the feed item the Matrix message is split.
	# This way N feed posts always create exactly N Matrix messages.
	# Inserting newlines with sed:
	#	https://unix.stackexchange.com/questions/429139/replace-newlines-with-sed-a-la-tr
	echo "$feeddata" | sed 'H;1h;$!d;x; s/\n\n\n\n\n/\n\n/g' |
		sed 'H;1h;$!d;x; s/\n\n\n\n/\n\n/g' | sed 'H;1h;$!d;x; s/\n\n\n/\n\n/g' |
		sed '/Pub.date: /a \\n\n' # add newlines for separation after last feed item line
}

if [ "$#" == "0" ]; then
	echo "Example Twitter user names are: aantonom adam3us balajis elonmusk naval NickZsabo4"
	echo "Try \"tweet elonmusk 2\" for example to get the latest 2 tweets from Elon."
	exit 0
fi

arg1=$1  # twitter user name, required
arg2=$2  # number of items (optional) or "notorify"
arg3=$3  # "notorify" or empty

if [ "$arg2" == "" ]; then
	arg2="1" # default, get only last item, if no number specified
fi

if [ "$arg2" == "notorify" ] || [ "$arg3" == "notorify" ]; then
	TORIFY=""
	echo "Are you sure you do not want to use TOR?"
	if [ "$arg2" == "notorify" ]; then
		arg2="1"
	fi
fi

case "$arg2" in
'' | *[!0-9]*)
	echo "Second argument is not a number. Skipping. Try \"tweet elonmusk 1\"."
	exit 0
	;;
*)
	# echo "First argument is a number. "
	;;
esac

function dofeed() {
	arg1="$1"
	arg2="$2"
	case "$arg1" in
	all)
		for feed in aantonop adam3us balajis Blockstream elonmusk naval jimmysong NickZsabo4; do
			dofeed "$feed" "$arg2"
			if [ "$?" == "1" ]; then
				echo "Giving up after first error. Sorry."
				return 1
			fi
			echo -e "\n\n\n"
		done
		;;
	*)
		readrss "https://twitrss.me/twitter_user_to_rss/?user=${arg1}" "$arg2"
		;;
	esac
}

dofeed "$arg1" "$arg2"

exit 0

# EOF
