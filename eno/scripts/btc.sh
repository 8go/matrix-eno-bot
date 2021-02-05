#!/bin/bash

# use TORIFY or TORPROXY, but do NOT use BOTH of them!
# TORIFY="torify"
TORIFY="" # replaced with TORPROXY, dont use both
TORPROXY=" --socks5-hostname localhost:9050 "

# tor and torify should be installed for your privacy.
type torify >/dev/null 2>&1 || {
    echo "It is recommended that you install the packge \"tor\" on the server for privacy."
    TORIFY=""
    TORPROXY=""
}

# $TORIFY curl --silent --compressed "https://data.messari.io/api/v1/assets/bitcoin/metrics" | jq '.data.market_data |
#	.percent_change_usd_last_24_hours, .real_volume_last_24_hours , .price_usd' 2>&1 #  2>> /dev/null

BASELIST=$($TORIFY curl $TORPROXY --silent --compressed "https://data.messari.io/api/v1/assets/bitcoin/metrics" |
    jq '.data.market_data | keys_unsorted[] as $k | "\($k), \(.[$k] )"' |
    grep -e price_usd -e real_volume_last_24_hours -e percent_change_usd_last_24_hours | tr -d "\"")
# returns something like
#	price_usd, 9632.330680167783
#	real_volume_last_24_hours, 1418555108.5501404
#	percent_change_usd_last_24_hours, 1.152004386319294
LC_ALL=en_US.UTF-8 printf "Price: %'.0f USD\n" "$(echo "$BASELIST" | grep price_usd | cut -d "," -f 2)"
LC_ALL=en_US.UTF-8 printf "Change: %'.1f %%\n" "$(echo "$BASELIST" | grep percent_change_usd_last_24_hours | cut -d "," -f 2)"
LC_ALL=en_US.UTF-8 printf "Volume: %'.0f USD\n" "$(echo "$BASELIST" | grep real_volume_last_24_hours | cut -d "," -f 2)"

# EOF
