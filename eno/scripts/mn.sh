#!/bin/bash

# mn.sh # returns 1 news article (the last)
# mn.sh 1 # returns 1 news article (the last)
# mn.sh 2 # returns 2 news articles (the last 2)
# mn.sh 15 # returns 15 news articles (the last 15)
# mn.sh y # return the news articles from yesterday (could be zero, one or more)
# mn.sh yesterday # return the news articles from yesterday (could be zero, one or more)
# mn.sh 2020-10-22 # return the news articles from a specific day, only this day (not "since this day")

# DEBUG="true"

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

if [ "$DEBUG" == "1" ]; then
    DEBUG="true"
fi

if [ "$#" == "0" ]; then
    arg1=1 # default value if none given by user
fi
if [ "$#" == "1" ] || [ "$#" == "2" ]; then
    case "${1,,}" in
    'y' | 'yesterday')
        ydate=$(date +%F --date='yesterday')
        [ "${DEBUG,,}" == "true" ] && echo "Getting yesterday's news for day \"$ydate\"."
        arg1='yesterday'
        ;;
    202[0-9]-[0-1][0-9]-[0-3][0-9])
        ydate=$1
        [ "${DEBUG,,}" == "true" ] && echo "Getting news for day \"$ydate\"."
        arg1=$1
        ;;
    'notor' | 'notorify' | '--notor' | '--notorify')
        echo "Torify and Tor Proxy have been turned off."
        TORIFY=""
        TORPROXY=""
        ;;
    '' | *[!0-9]*)
        echo "First argument is not a number. Skipping. Try \"mn\" or \"mn 2\"."
        exit 1
        ;;
    *)
        # echo "First argument is a number. "
        arg1=$1
        ;;
    esac
fi
if [ "$#" == "2" ]; then
    case "${2,,}" in
    'notor' | 'notorify' | '--notor' | '--notorify')
        echo "Torify and Tor Proxy have been turned off."
        TORIFY=""
        TORPROXY=""
        ;;
    *)
        echo "Invalid second argument. Try \"mn\", \"mn 2\", or  \"mn 2 notor\"."
        exit 2
        ;;
    esac
fi
if [ $# -gt 2 ]; then
    echo "Too many arguments. Expected at most 2, but found $#. Try \"mn\", \"mn 2\", or  \"mn 2 notor\"."
    exit 3
fi

function dojson() {
    [ "${DEBUG,,}" == "true" ] && echo "DEBUG: You requested \"${arg1,,}\" news article"
    case "${arg1,,}" in
    'y' | 'yesterday' | 202[0-9]-[0-1][0-9]-[0-3][0-9])
        x=0
        while :; do
            mndate=$(echo "$mnjson" | jq ".data[$x].published_at")
            # echo "MN article $x is from date $mndate."
            mndate=${mndate:1:10} # is of form "2020-08-31" INCLUDING quotes!
            # echo "MN article $x is from date $mndate and comparing it to date $ydate."
            if [[ "$mndate" < "$ydate" ]]; then
                # echo "mn date $mndate < ydate  $ydate. Exiting"
                break # jump out of infinite loop
            fi
            if [ "$mndate" == "$ydate" ]; then
                echo "$mnjson" | jq ".data[$x] | .url, .title , .content " | sed 's/\\n/\'$'\n''/g' | sed 's/\!\[\]//g' 2>>/dev/null
            fi
            x=$(($x + 1))
            if [[ "$mndate" > "$ydate" ]]; then
                continue # go to next element
            fi
        done
        ;;
    '' | 1)
        [ "${DEBUG,,}" == "true" ] && echo "You requested 1 news article"
        echo "$mnjson" | jq '.data[0] | .url, .title , .content ' | sed 's/\\n/\'$'\n''/g' | sed 's/\!\[\]//g' 2>>/dev/null
        ;;
    2)
        [ "${DEBUG,,}" == "true" ] && echo "You requested ${arg1,,} news articles"
        echo "$mnjson" | jq '.data[0,1] | .url, .title , .content ' | sed '0~3 s/$/\n\n/g' 2>>/dev/null
        ;;
    3)
        [ "${DEBUG,,}" == "true" ] && echo "You requested ${arg1,,} news articles"
        echo "$mnjson" | jq '.data[0,1,2] | .url, .title , .content ' | sed '0~3 s/$/\n\n/g' 2>>/dev/null
        ;;
    4)
        [ "${DEBUG,,}" == "true" ] && echo "You requested ${arg1,,} news articles"
        echo "$mnjson" | jq '.data[0,1,2,3] | .url, .title , .content ' | sed '0~3 s/$/\n\n/g' 2>>/dev/null
        ;;
    5)
        [ "${DEBUG,,}" == "true" ] && echo "You requested ${arg1,,} news articles"
        echo "$mnjson" | jq '.data[0,1,2,3,4] | .url, .title , .content ' | sed '0~3 s/$/\n\n/g' 2>>/dev/null
        ;;
    6)
        [ "${DEBUG,,}" == "true" ] && echo "You requested ${arg1,,} news articles"
        echo "$mnjson" | jq '.data[0,1,2,3,4,5] | .url, .title , .content ' | sed '0~3 s/$/\n\n/g' 2>>/dev/null
        ;;
    7)
        [ "${DEBUG,,}" == "true" ] && echo "You requested ${arg1,,} news articles"
        echo "$mnjson" | jq '.data[0,1,2,3,4,5,6] | .url, .title , .content ' | sed '0~3 s/$/\n\n/g' 2>>/dev/null
        ;;
    8)
        [ "${DEBUG,,}" == "true" ] && echo "You requested ${arg1,,} news articles"
        echo "$mnjson" | jq '.data[0,1,2,3,4,5,6,7] | .url, .title , .content ' | sed '0~3 s/$/\n\n/g' 2>>/dev/null
        ;;
    9)
        [ "${DEBUG,,}" == "true" ] && echo "You requested ${arg1,,} news articles"
        echo "$mnjson" | jq '.data[0,1,2,3,4,5,6,7,8] | .url, .title , .content ' | sed '0~3 s/$/\n\n/g' 2>>/dev/null
        ;;
    10)
        [ "${DEBUG,,}" == "true" ] && echo "You requested ${arg1,,} news articles"
        echo "$mnjson" | jq '.data[0,1,2,3,4,5,6,7,8,9] | .url, .title , .content ' | sed '0~3 s/$/\n\n/g' 2>>/dev/null
        ;;
    11)
        [ "${DEBUG,,}" == "true" ] && echo "You requested ${arg1,,} news articles"
        echo "$mnjson" | jq '.data[0,1,2,3,4,5,6,7,8,9,10] | .url, .title , .content ' | sed '0~3 s/$/\n\n/g' 2>>/dev/null
        ;;
    12)
        [ "${DEBUG,,}" == "true" ] && echo "You requested ${arg1,,} news articles"
        echo "$mnjson" | jq '.data[0,1,2,3,4,5,6,7,8,9,10,11] | .url, .title , .content ' | sed '0~3 s/$/\n\n/g' 2>>/dev/null
        ;;
    13)
        [ "${DEBUG,,}" == "true" ] && echo "You requested ${arg1,,} news articles"
        echo "$mnjson" | jq '.data[0,1,2,3,4,5,6,7,8,9,10,11,12] | .url, .title , .content ' | sed '0~3 s/$/\n\n/g' 2>>/dev/null
        ;;
    14)
        [ "${DEBUG,,}" == "true" ] && echo "You requested ${arg1,,} news articles"
        echo "$mnjson" | jq '.data[0,1,2,3,4,5,6,7,8,9,10,11,12,13] | .url, .title , .content ' | sed '0~3 s/$/\n\n/g' 2>>/dev/null
        ;;
    15)
        [ "${DEBUG,,}" == "true" ] && echo "You requested ${arg1,,} news articles"
        echo "$mnjson" | jq '.data[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14] | .url, .title , .content ' | sed '0~3 s/$/\n\n/g' 2>>/dev/null
        ;;
    *)
        echo "You want too many articles or you want something foolish. You asked for \"${arg1,,}\". I will give you 1 news article"
        echo "$mnjson" | jq '.data[0] | .url, .title , .content ' 2>>/dev/null
        ;;
    esac
} # dojson() function

# https://messari.io/api/docs#tag/News
mnjson=$($TORIFY curl $TORPROXY --silent --compressed "https://data.messari.io/api/v1/news?fields=title,content,url,published_at&as-markdown&page=1")
# TESTDATA mnjson="<html><title>500 Service Error</title><h1>500 Service Error</h1></html>"
[ "${DEBUG,,}" == "true" ] && echo -e "DEBUG: REST query returned this data (first 256 bytes): \n${mnjson:0:255}\n"
firstline=$(echo "$mnjson" | head -n 1)
if [[ "${firstline,,}" =~ \<html\>.* ]]; then
    echo "There was a problem. Messari did not return a JSON object but an HTML page."
    echo "$(echo "$mnjson" | grep -i "<title>" -)"
    echo "$(echo "$mnjson" | grep -i "<h1>" -)"
    exit 4
fi
dojson

# Asset-based news is the SAME news (subset) of the general news
# echo -e "\n\n\nBTC news:"
# mnjson=$($TORIFY curl $TORPROXY --silent --compressed "https://data.messari.io/api/v1/news?assetKey=BTC&fields=title,content,url,published_at&as-markdown&page=1")
# dojson
#
# echo -e "\n\n\nETH news:"
# mnjson=$($TORIFY curl $TORPROXY --silent --compressed "https://data.messari.io/api/v1/news?assetKey=ETH&fields=title,content,url,published_at&as-markdown&page=1")
# dojson

# EOF
