#!/bin/bash

# Put your password hash here
PASSWD_HASH="PutYourPasswordHashHere0123456789abcdef0123456789abcdef012345678"
# Put the MAC address of your PC that you want to wake up here, configure its BIOS for Wake-on-LAN
MAC1="Ma:cO:fY:ou:rP:c0"
# Nickname of PC to wake up
NICK1A="myPc1"
NICK1A="myPcA"

# or put these 4 vars into the ./config.rc config file as
# variables WAKE_PASSWD_HASH, WAKE_MAC1, WAKE_NICK1A and WAKE_NICK1B

if [ -f "$(dirname "$0")/config.rc" ]; then
    [ "$DEBUG" == "1" ] && echo "Sourcing $(dirname "$0")/config.rc"
    # shellcheck disable=SC1090
    source "$(dirname "$0")/config.rc" # if it exists, optional, not needed, allows to set env variables
    PASSWD_HASH="$WAKE_PASSWD_HASH"
    MAC1="$WAKE_MAC1"
    NICK1A="$WAKE_NICK1A"
    NICK1B="$WAKE_NICK1B"
fi

if [ "$#" == "0" ]; then
    echo "You must specify which PC to wake up. Try \"wake myPc1\" or similar."
    exit 0
fi

if [[ "$MAC1" == "" ]]; then
    echo "MAC address not provided. Cannot wake PC without it."
    exit
fi

arg1=$1
arg2=$2

# $1: which PC to wake up
# $2: possible password
function dowake() {
    arg1="$1"
    arg2="$2"
    case "${arg1,,}" in
    "world")
        echo "Waking up the world. Good morning Earth!"
        ;;
    "$NICK1A" | "$NICK1B")
        # in order to wake up host, one must provide a password
        # we compare the hashes here
        if [ "$(echo "$arg2" | sha256sum | cut -d ' ' -f 1)" == "$PASSWD_HASH" ]; then
            echo "The bot will wake up host \"$arg1\"."
            wakeonlan "$MAC1"
        else
            echo "Argument missing or argument wrong. Command ignored due to lack of permissions."
        fi
        ;;
    *)
        echo "The bot does not know how to wake up host \"${arg1}\"."
        echo "Only hosts \"$NICK1A\" and \"$NICK1B\" are configured on server."
        ;;
    esac
}

dowake "$arg1" "$arg2"

exit 0

# EOF
