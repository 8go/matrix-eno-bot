#!/bin/bash

# use TORIFY or TORPROXY, but do NOT use BOTH of them!
# TORIFY="torify"
TORIFY="" # replaced with TORPROXY, dont use both
TORPROXY=" --tor "

# tor and torify should be installed for your privacy.
type torify >/dev/null 2>&1 || {
    echo "It is recommended that you install the packge \"tor\" on the server for privacy."
    TORIFY=""
    TORPROXY=""
}

arg1=$1
arg2=$2

if [[ "$arg1" == "+" ]] || [[ "$arg1" == "more" ]] || [[ "$arg1" == "plus" ]] || [[ "$arg1" == "v" ]] || [[ "$arg2" == "+" ]] || [[ "$arg2" == "more" ]] || [[ "$arg2" == "plus" ]] || [[ "$arg2" == "v" ]]; then
    FORMAT=""
else
    FORMAT="--terse"
fi

if [[ "${arg1,,}" == "notorify" ]] || [[ "${arg1,,}" == "notor" ]] || [[ "${arg2,,}" == "notorify" ]] || [[ "${arg2,,}" == "notor" ]]; then
    # echo "Turning Tor use off."
    TORIFY=""
    TORPROXY=""
fi

# s2f must be installed
type s2f.py >/dev/null 2>&1 || {
    # it was not found in normal path, lets see if we can  amplify the PATH by sourcing profile files
    . $HOME/.bash_profile 2>/dev/null
    . $HOME/.profile 2>/dev/null
    type s2f.py >/dev/null 2>&1 || {
        echo "For s2f to work you must first install the file \"s2f.py\" on the server."
        echo "Download from https://github.com/8go/bitcoin-stock-to-flow"
        echo "Set your PATH if you have installed it but it cannot be found."
        exit 0
    }
}

$TORIFY s2f.py $TORPROXY $FORMAT | grep -v "Calculated" | grep -v "Data sources" # this displays nicer with format "code"

# EOF
