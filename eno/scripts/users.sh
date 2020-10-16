#!/bin/bash

# PUT YOUR CORRECT ACCESS TOKEN HERE, THIS ACCESS TOKEN MUST HAVE ADMIN RIGHTS
# see documentation how to add admin rights to normal access token
MYACCESSTOKENWITHADMINPERMISSIONS="VERY-LONG-CRYTOGRAHIC-STRING-THAT-IS-YOUR-ACCESS-TOKEN-WITH-ADMIN-PERMISSIONS"
MYHOMESERVER="https://matrix.example.com"
# or put these 2 vars into the ./config.rc config file as
# variables USERS_MYACCESSTOKENWITHADMINPERMISSIONS and USERS_MYHOMESERVER

if [ -f "$(dirname "$0")/config.rc" ]; then
    [ "$DEBUG" == "1" ] && echo "Sourcing $(dirname "$0")/config.rc"
    # shellcheck disable=SC1090
    source "$(dirname "$0")/config.rc" # if it exists, optional, not needed, allows to set env variables
    MYACCESSTOKENWITHADMINPERMISSIONS="${USERS_MYACCESSTOKENWITHADMINPERMISSIONS}"
    MYHOMESERVER="${USERS_MYHOMESERVER}"
fi

if [[ "$MYACCESSTOKENWITHADMINPERMISSIONS" == "" ]] || [[ "$MYHOMESERVER" == "" ]]; then
    echo "Either homeserver or access token not provided. Cannot list users without them."
    exit
fi

# myMatrixListUsersSql.sh | cut -d '|' -f 1 | grep -v myMatrixListUsersSql.sh
# If I call sqlite3 here it locks the db and on second+ call it gives error stating that db is locked.
# So, it is better to use the official Matrix Synapse REST API.

# echo "$MYACCESSTOKENWITHADMINPERMISSIONS" |
#	myMatrixListUsersJson.sh | grep -v myMatrixListUsersJson.sh | grep -v "https://" | jq '.users[] | .name' | tr -d '"'
echo "List of at most 100 users:"
curl --silent --header "Authorization: Bearer $MYACCESSTOKENWITHADMINPERMISSIONS" "$MYHOMESERVER/_synapse/admin/v2/users?from=0&limit=100&guests=false" |
    jq '.users[] | .name' | tr -d '"'

# EOF
