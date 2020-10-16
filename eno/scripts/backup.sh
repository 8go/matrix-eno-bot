#!/bin/bash


# mybackup must be installed
type mybackup.sh >/dev/null 2>&1 || {
        # it was not found in normal path, lets see if we can  amplify the PATH by sourcing profile files
        . $HOME/.bash_profile 2> /dev/null
        . $HOME/.profile 2> /dev/null
        type mybackup.sh >/dev/null 2>&1 || {
                echo "This script requires that you install the script \"mybackup.sh\" on the server."
                exit 0
        }
}

# echo "***$(date +%F\ %R)*** BACKUP: ***" 
mybackup.sh "--terse"

# EOF
