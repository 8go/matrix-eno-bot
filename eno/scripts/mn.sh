#!/bin/bash

TORIFY="torify"

# tor and torify should be installed for your privacy.
type torify >/dev/null 2>&1 || {
    echo "It is recommended that you install the packge \"tor\" on the server for privacy."
    TORIFY=""
}

if [ "$#" == "0" ]; then
    arg1=1 # default value if none given by user
else
    case "${1,,}" in
    'y' | 'yesterday')
        set -- "yesterday" # set $1 to "yesterday"
        ydate=$(date +%F --date='yesterday')
        # echo "Getting yesterday's news for day $ydate."
        arg1=$1
        ;;
    '' | *[!0-9]*)
        echo "First argument is not a number. Skipping. Try \"mn\" or \"mn 2\"."
        exit 0
        ;;
    *)
        # echo "First argument is a number. "
        arg1=$1
        ;;
    esac
fi

function dojson() {
    case "${arg1,,}" in
    'yesterday')
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
                echo "$mnjson" | jq ".data[$x] | .url, .title , .content "
            fi
            x=$(($x + 1))
            if [[ "$mndate" > "$ydate" ]]; then
                continue # go to next element
            fi
        done
        ;;
    '' | 1)
        echo "$mnjson" | jq '.data[0] | .url, .title , .content ' 2>>/dev/null
        ;;
    2)
        echo "$mnjson" | jq '.data[0,1] | .url, .title , .content ' | sed '0~3 s/$/\n\n/g' 2>>/dev/null
        ;;
    3)
        echo "$mnjson" | jq '.data[0,1,2] | .url, .title , .content ' | sed '0~3 s/$/\n\n/g' 2>>/dev/null
        ;;
    4)
        echo "$mnjson" | jq '.data[0,1,2,3] | .url, .title , .content ' | sed '0~3 s/$/\n\n/g' 2>>/dev/null
        ;;
    5)
        echo "$mnjson" | jq '.data[0,1,2,3,4] | .url, .title , .content ' | sed '0~3 s/$/\n\n/g' 2>>/dev/null
        ;;
    6)
        echo "$mnjson" | jq '.data[0,1,2,3,4,5] | .url, .title , .content ' | sed '0~3 s/$/\n\n/g' 2>>/dev/null
        ;;
    7)
        echo "$mnjson" | jq '.data[0,1,2,3,4,5,6] | .url, .title , .content ' | sed '0~3 s/$/\n\n/g' 2>>/dev/null
        ;;
    8)
        echo "$mnjson" | jq '.data[0,1,2,3,4,5,6,7] | .url, .title , .content ' | sed '0~3 s/$/\n\n/g' 2>>/dev/null
        ;;
    9)
        echo "$mnjson" | jq '.data[0,1,2,3,4,5,6,7,8] | .url, .title , .content ' | sed '0~3 s/$/\n\n/g' 2>>/dev/null
        ;;
    10)
        echo "$mnjson" | jq '.data[0,1,2,3,4,5,6,7,8,9] | .url, .title , .content ' | sed '0~3 s/$/\n\n/g' 2>>/dev/null
        ;;
    11)
        echo "$mnjson" | jq '.data[0,1,2,3,4,5,6,7,8,9,10] | .url, .title , .content ' | sed '0~3 s/$/\n\n/g' 2>>/dev/null
        ;;
    12)
        echo "$mnjson" | jq '.data[0,1,2,3,4,5,6,7,8,9,10,11] | .url, .title , .content ' | sed '0~3 s/$/\n\n/g' 2>>/dev/null
        ;;
    13)
        echo "$mnjson" | jq '.data[0,1,2,3,4,5,6,7,8,9,10,11,12] | .url, .title , .content ' | sed '0~3 s/$/\n\n/g' 2>>/dev/null
        ;;
    14)
        echo "$mnjson" | jq '.data[0,1,2,3,4,5,6,7,8,9,10,11,12,13] | .url, .title , .content ' | sed '0~3 s/$/\n\n/g' 2>>/dev/null
        ;;
    15)
        echo "$mnjson" | jq '.data[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14] | .url, .title , .content ' | sed '0~3 s/$/\n\n/g' 2>>/dev/null
        ;;
    *)
        echo "You want too many or you want something foolish. I will give you 1 news article"
        echo "$mnjson" | jq '.data[0] | .url, .title , .content ' 2>>/dev/null
        ;;
    esac
} # dojson() function

# https://messari.io/api/docs#tag/News
mnjson=$($TORIFY curl --silent --compressed "https://data.messari.io/api/v1/news?fields=title,content,url,published_at&as-markdown&page=1")
#echo "$mnjson"
dojson

# Asset-based news is the SAME news (subset) of the general news
# echo -e "\n\n\nBTC news:"
# mnjson=$($TORIFY curl --silent --compressed "https://data.messari.io/api/v1/news?assetKey=BTC&fields=title,content,url,published_at&as-markdown&page=1")
# dojson
#
# echo -e "\n\n\nETH news:"
# mnjson=$($TORIFY curl --silent --compressed "https://data.messari.io/api/v1/news?assetKey=ETH&fields=title,content,url,published_at&as-markdown&page=1")
# dojson

# EOF
