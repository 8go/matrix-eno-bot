#!/bin/bash

# Put your password hash here
PASSWD_HASH="PutYourPasswordHashHere0123456789abcdef0123456789abcdef012345678"
# or put it into the ./config.rc config file as var RESTART_DEFAULT_PASSWD_HASH

if [ -f "$(dirname "$0")/config.rc" ]; then
    [ "$DEBUG" == "1" ] && echo "Sourcing $(dirname "$0")/config.rc"
    # shellcheck disable=SC1090
    source "$(dirname "$0")/config.rc" # if it exists, optional, not needed, allows to set env variables
    PASSWD_HASH="${RESTART_DEFAULT_PASSWD_HASH}"
fi

if [ "$#" == "0" ]; then
    echo "You must be restarting something. Try \"restart bot\" or \"restart matrix\"."
    echo "\"bot\", \"matrix\", \"os\", and \"world\" are configured on server."
    exit 0
fi
arg1=$1
arg2=$2

function dorestart() {
    arg1="$1"
    arg2="$2"
    case "${arg1,,}" in
    "bot" | "eno")
        echo "The bot will reset itself."
        # THIS WILL ONLY WORK IF THE ACCOUNT UNDER WHICH THIS IS EXECUTED HAS PERMISSIONS TO DO SUDO!
        p="matrix-eno-bot"
        sudo systemctl restart "$p" ||
            {
                echo "Error while trying to restart service \"$p\". systemctl restart \"$p\" failed. Maybe due to missing permissions?"
                return 0
            }
        # the following output will go nowhere, nothing will be returned to user
        echo "The bot did restart."
        systemctl status matrix-eno-bot
        ;;
    "world")
        echo "Reseting world order. Done!"
        ;;
    "matrix")
        echo "The bot will reset Matrix service"
        # the name of the service might vary based on installation from : synapse-matrix, matrix, etc.
        # let's be reckless and reset all services that contain "matrix" in their name
        # THIS WILL ONLY WORK IF THE ACCOUNT UNDER WHICH THIS IS EXECUTED HAS PERMISSIONS TO DO SUDO!
        service --status-all | grep -i matrix | tr -s " " | cut -d " " -f 5 | while read -r p; do
            sudo systemctl stop "$p" ||
                {
                    echo "Error while trying to stop service \"$p\". systemctl stop \"$p\" failed. Maybe due to missing permissions?"
                    return 0
                }
            sleep 1
            echo "Service \"$p\" was stopped successfully."
            sudo systemctl start "$p" ||
                {
                    echo "Error while trying to start service \"$p\". systemctl start \"$p\" failed. Maybe due to missing permissions?"
                    return 0
                }
            sleep 1
            echo "Service \"$p\" was started successfully."
            echo "Status of service \"$p\" is:"
            systemctl status "$p"
        done
        # output will be shown by bot after Matrix restarts and bot reconnects.
        ;;
    "os")
        # in order to reboot OS, one must provide a password
        # we compare the hashes here
        if [ "$(echo "$arg2" | sha256sum | cut -d ' ' -f 1)" == "$PASSWD_HASH" ]; then
            echo "The bot will reboot the server"
            sudo systemctl reboot
        else
            echo "Argument missing or argument wrong. Command ignored due to lack of permissions."
        fi
        ;;
    *)
        echo "The bot does not know how to restart \"${arg1}\"."
        echo "Only \"bot\", \"matrix\", \"os\", and \"world\" are configured on server."
        ;;
    esac
}

dorestart "$arg1" "$arg2"

exit 0

# EOF
