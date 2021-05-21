#!/bin/bash

# ddgr must be installed
type ddgr >/dev/null 2>&1 || {
	echo "For duckduckgo search to work you must first install the packge \"ddgr\" on the server."
	exit 0
}

if [ "$#" == "0" ]; then
	echo "You must be looking for something. Try \"ddg matrix news\"."
	exit 0
fi

ddgr --np -n=10 -C "$@"

exit 0

# EOF
