#!/bin/bash

TORIFY="torify"

# tor and torify should be installed for your privacy.
type torify >/dev/null 2>&1 || {
	echo "It is recommended that you install the packge \"tor\" on the server for privacy."
	TORIFY=""
}

function gethackernewsfromweb() {
	$TORIFY w3m -dump news.ycombinator.com 2>&1 | grep -v -E 'points.*comments' |
		grep -v -E ' points by .* minutes ago | hide | discuss' |
		grep -v -E ' ago | hide' |
		grep -v 'Guidelines | FAQ | Support | API | Security | Lists | Bookmarklet' |
		grep -v "Legal | Apply to YC | Contact" |
		grep -v -E ' *Search: \[ *\]$' |
		grep -v "        submit" |
		grep -v "           More" |
		grep -v -E '     \*$' | sed '/^[[:space:]]*$/d' | sed 's/^......//'
	# remove lines with only whitespaces, remove leading 6 characters
}

HNSH="$HOME/Scripts/hn.sh"
# hn script installed?
# If hn.sh script is not installed, no problem, we get the data from the web.
type "$HNSH" >/dev/null 2>&1 || {
	echo "Getting Hacker News from web: "
	gethackernewsfromweb
	exit 0
}

if [ "$#" == "0" ]; then
	gethackernewsfromweb
	exit 0
fi
case "$1" in
'' | *[!0-9]*)
	echo "First argument is not a number. Skipping. Try \"hn\" or \"hn 5\"."
	exit 0
	;;
*)
	# echo "First argument is a number. "
	;;
esac
$HNSH "$1" | grep -v -e "points" -e "comments" | grep -v lurker | grep -v Initializing | grep -v "Fetching posts"
exit 0

# EOF
