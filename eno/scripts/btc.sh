#!/bin/bash

# use TORIFY or TORPROXY, but do NOT use BOTH of them!
# TORIFY="torify"
TORIFY="" # replaced with TORPROXY, don't use both
TORPROXY=" --socks5-hostname localhost:9050 "

# tor and torify should be installed for your privacy.
type torify > /dev/null 2>&1 || {
  echo "It is recommended that you install the packge \"tor\" on the server for privacy."
  TORIFY=""
  TORPROXY=""
}

if [ "$DEBUG" == "1" ] || [ "${DEBUG,,}" == "true" ]; then
  DEBUG="true"
fi
if [ $# -gt 1 ]; then
  echo "Too many arguments."
  exit 1
fi
if [ "$#" == "1" ]; then
  case "${1,,}" in
  'notor' | 'notorify' | '--notor' | '--notorify')
    [ "${DEBUG}" == "true" ] && echo "Torify and Tor Proxy will be turned off."
    TORIFY=""
    TORPROXY=""
    ;;
  *)
    echo "Unknown argument $*."
    exit 1
    ;;
  esac
fi

# # OPTION 1: MESSARI SOURCE
# # disadvantage: does not have EUR price
# # $TORIFY curl --silent --compressed "https://data.messari.io/api/v1/assets/bitcoin/metrics" | jq '.data.market_data |
# #	.percent_change_usd_last_24_hours, .real_volume_last_24_hours , .price_usd' 2>&1 #  2>> /dev/null
#
# BASELIST=$($TORIFY curl $TORPROXY --silent --compressed "https://data.messari.io/api/v1/assets/bitcoin/metrics" |
#     jq '.data.market_data | keys_unsorted[] as $k | "\($k), \(.[$k] )"' |
#     grep -e price_usd -e real_volume_last_24_hours -e percent_change_usd_last_24_hours | tr -d "\"")
# # returns something like
# #	price_usd, 9632.330680167783
# #	real_volume_last_24_hours, 1418555108.5501404
# #	percent_change_usd_last_24_hours, 1.152004386319294
# if [ "$BASELIST" == "" ]; then
#     echo "Error: No data available. Are you sure the network is up?"
#     if [ "${TORIFY}" != "" ] || [ "${TORPROXY}" != "" ]; then
#         echo "Error: Are you sure Tor is running? Start Tor or add 'notor' as argument!"
#     fi
#     exit 1
# fi
# LC_ALL=en_US.UTF-8 printf "Price: %'.0f USD\n" "$(echo "$BASELIST" | grep price_usd | cut -d "," -f 2)"
# LC_ALL=en_US.UTF-8 printf "Change: %'.1f %%\n" "$(echo "$BASELIST" | grep percent_change_usd_last_24_hours | cut -d "," -f 2)"
# LC_ALL=en_US.UTF-8 printf "Volume: %'.0f USD\n" "$(echo "$BASELIST" | grep real_volume_last_24_hours | cut -d "," -f 2)"

# OPTION 2: COINDESK SOURCE
# disadvantage: does not have % change
# https://api.coindesk.com/v1/bpi/currentprice.json
# returns:
# { "time":{"updated":"Mar 2, 2021 18:14:00 UTC","updatedISO":"2021-03-02T18:14:00+00:00","updateduk":"Mar 2, 2021 at 18:14 GMT"},
#   "disclaimer":"This ...","chartName":"Bitcoin",
#   "bpi":{"USD":{"code":"USD","symbol":"&#36;","rate":"48,011.8840","description":"United States Dollar","rate_float":48011.884},...,
#          "EUR":{"code":"EUR","symbol":"&euro;","rate":"39,745.6779","description":"Euro","rate_float":39745.6779}}}
BASELIST2=$($TORIFY curl $TORPROXY --silent --compressed "https://api.coindesk.com/v1/bpi/currentprice.json" |
  jq '.bpi.EUR.rate_float, .bpi.USD.rate_float')
if [ "$BASELIST2" == "" ]; then
  echo "Error: No data available. Are you sure the network is up?"
  if [ "${TORIFY}" != "" ] || [ "${TORPROXY}" != "" ]; then
    echo "Error: Are you sure Tor is running? Start Tor or add 'notor' as argument!"
  fi
  exit 1
fi

LC_ALL=en_US.UTF-8 dm1=$(date +%F --date='yesterday')
LC_ALL=en_US.UTF-8 dm2=$(date +%F --date='2 days ago')
LC_ALL=en_US.UTF-8 dm3=$(date +%F --date='3 days ago')
# {"bpi":{"2013-09-01":128.2597,"2013-09-02":127.3648,"2013-09-03":127.5915,"2013-09-04":120.5738,"2013-09-05":120.5333},
#  "disclaimer":"This data ...","time":{"updated":"Sep 6, 2013 00:03:00 UTC","updatedISO":"2013-09-06T00:03:00+00:00"}}
# shellcheck disable=SC2089
jqargs=".bpi.\"${dm1}\",.bpi.\"${dm2}\",.bpi.\"${dm3}\""
BASELIST3=$($TORIFY curl $TORPROXY --silent --compressed "https://api.coindesk.com/v1/bpi/historical/close.json?start=${dm3}&end=${dm1}" |
  jq "$jqargs")
price_dm0="$(echo "$BASELIST2" | tail -n 1)"                              # price USD today
price_em0="$(echo "$BASELIST2" | head -n 1)"                              # price EUR today
price_dm1="$(echo "$BASELIST3" | head -n 1)"                              # price USD yesterday
price_dm2="$(echo "$BASELIST3" | head -n 2 | tail -n 1)"                  # price USD 2 days ago
price_dm3="$(echo "$BASELIST3" | tail -n 1)"                              # price USD 3 days ago
change_dm1=$(echo "scale=4; ($price_dm0-$price_dm1)/$price_dm1*100" | bc) # today's change compared to yesterday
change_dm2=$(echo "scale=4; ($price_dm0-$price_dm2)/$price_dm2*100" | bc) # today's change compared to yesterday
change_dm3=$(echo "scale=4; ($price_dm0-$price_dm3)/$price_dm3*100" | bc) # today's change compared to yesterday
chartdown_emoji=📉
chartup_emoji=📈
dollar_emoji=💵
euro_emoji=💶
[[ $change_dm1 == -* ]] && chart1=$chartdown_emoji || chart1=$chartup_emoji
[[ $change_dm2 == -* ]] && chart2=$chartdown_emoji || chart2=$chartup_emoji
[[ $change_dm3 == -* ]] && chart3=$chartdown_emoji || chart3=$chartup_emoji
# price, and trend in comparison to yesterday close
LC_ALL=en_US.UTF-8 printf "Price: %'.0f EUR € %s %s\n" "$price_em0" "$euro_emoji" "$chart1"
LC_ALL=en_US.UTF-8 printf "Price: %'.0f USD \$ %s %s\n" "$price_dm0" "$dollar_emoji" "$chart1"
# today's price in satoshis per dollar (euro), today $1 gets you so many satoshis
LC_ALL=en_US.UTF-8 printf "Price: €1 gets you %'.0f sats %s\n" "$(echo "scale=4; 100000000/$price_em0" | bc)" "$euro_emoji"
LC_ALL=en_US.UTF-8 printf "Price: \$1 gets you %'.0f sats %s\n" "$(echo "scale=4; 100000000/$price_dm0" | bc)" "$dollar_emoji"
# todays price compared to the price from last days, trend, if positiv then today's priceis higher, i.e. the price has gone up.
LC_ALL=en_US.UTF-8 printf "Price: %'.0f USD (yesterday)   %+'5.1f %% %s \n" "$(echo "$BASELIST3" | head -n 1)" "$change_dm1" "$chart1"
LC_ALL=en_US.UTF-8 printf "Price: %'.0f USD (2 days ago)  %+'5.1f %% %s \n" "$(echo "$BASELIST3" | head -n 2 | tail -n 1)" "$change_dm2" "$chart2"
LC_ALL=en_US.UTF-8 printf "Price: %'.0f USD (3 days ago)  %+'5.1f %% %s \n" "$(echo "$BASELIST3" | tail -n 1)" "$change_dm3" "$chart3"

# EOF
