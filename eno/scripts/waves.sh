#!/bin/bash

TORIFY="torify"

# tor and torify should be installed for your privacy.
type torify >/dev/null 2>&1 || {
    echo "It is recommended that you install the packge \"tor\" on the server for privacy."
    TORIFY=""
}

# xmllint must be installed
type xmllint >/dev/null 2>&1 || {
    # see: https://github.com/fcambus/ansiweather
    echo "This script requires that you install the packge \"xmllint\" (libxml2-utils) on the server."
    exit 0
}

if [ -f "$(dirname "$0")/config.rc" ]; then
    [ "$DEBUG" == "1" ] && echo "Sourcing $(dirname "$0")/config.rc"
    # shellcheck disable=SC1090
    source "$(dirname "$0")/config.rc" # if it exists, optional, not needed, allows to set env variables
fi

# $1: location, city
# $2: optional, "full" for more details
function getwaves() {
    if [[ "$1" == "" ]]; then echo "No waves report for empty location. Set location.";  return; fi
    if [[ "$2" == "full" ]] || [[ "$2" == "f" ]] || [[ "$2" == "more" ]] || [[ "$2" == "+" ]]; then
        # give a full, long listing of forecast
        echo "To be implemented" # to be implemented
    elif [[ "$2" == "short" ]] || [[ "$2" == "less" ]] || [[ "$2" == "s" ]] || [[ "$2" == "l" ]] || [[ "$2" == "-" ]]; then
        # give a short, terse listing of forecast
        echo "To be implemented" # to be implemented
    else
        # give a mediaum, default listing of waves/surf, just today
        echo "========== ${1%%/*} =========="

        x=1 # try 10 times
        while [ $x -le 10 ]; do
            # shellcheck disable=SC2086
            fullpage=$($TORIFY wget -q -O - https://magicseaweed.com/${1} 2>/dev/null)
            nowsummaryblock=$(echo $fullpage | xmllint --html --xpath '//div[@class="msw-col-fluid-inner"]/div[@class="row margin-bottom"]/div[@class="col-lg-7 col-md-7 col-sm-12 col-xs-12 msw-fc-current"]/div[@class="row"]/div[@class="col-lg-7 col-md-7 col-sm-7 col-xs-12"]' - 2>/dev/null)
            wavesnow=$(echo $fullpage | xmllint --html --xpath '//div[@class="msw-col-fluid-inner"]/div[@class="row margin-bottom"]/div[@class="col-lg-7 col-md-7 col-sm-12 col-xs-12 msw-fc-current"]/div[@class="row"]/div[@class="col-lg-7 col-md-7 col-sm-7 col-xs-12"]/ul[@class="rating rating-large clearfix"]/li[1]' - 2>/dev/null | sed -e 's/<[^>]*>//g' | xargs 2>/dev/null)
            weathernow=$(echo $nowsummaryblock | xmllint --html --xpath '//p[1]' - 2>/dev/null | sed -e 's/<[^>]*>//g' | sed -e 's/&Acirc;&deg;c/C/g' | sed -e 's/&Acirc;&deg;f/F/g' | sed -e 's/°c/C/g' | sed -e 's/°f/F/g' | sed -e 's/Â//g' | sed -e '1!b;s/^ /Wind /'  | sed -e 's/     /; Weather  /g' | sed -e 's/Air/; Air Temp /g' | sed -e 's/Sea/; Sea Temp /g' | tr -s ' ' | sed -e 's/ ;/;/g' | sed -e 's/ $//' | sed -e 's/ C$/C/' | sed -e 's/ F$/F/' | sed -e 's/; Weather//' | sed -e 's/^ //')
            # todayblock=$(echo $fullpage | xmllint --html --xpath '//div[@class="scrubber-bars-container"]/div[@class="row margin-bottom"]/div[@class="col-lg-7 col-md-7 col-sm-12 col-xs-12 msw-fc-current"]/div[@class="row"]/div[@class="col-lg-7 col-md-7 col-sm-7 col-xs-12"]' - 2>/dev/null)
            # old version: till May 2022:  todayconditions=$(echo $fullpage | xmllint --html --xpath '//div[@class="table-responsive-xs"]/table/tbody[1]/tr[@class=" is-first row-hightlight"]' - 2>/dev/null | sed -e 's/&Acirc;&deg;c/C/g' | sed -e 's/&Acirc;&deg;f/F/g' | sed -e 's/°c/C/g' | sed -e 's/°f/F/g' | sed -e 's/<[^>]*>//g' | sed -e 's/%/%\n/g' | column -t -s' ')
            # index 4 is 6am, index 5 is 9am, index 6 is noon, index 7 is 3pm, index 8 is 6pm
            line=$(echo -e "Time\tSurf\tSwell\tFr\t\tWind\tAir") # Title, Heading of Table
            for i in 4 5 6 7 8 ; do
                todaytablerow=$(echo $fullpage | xmllint --html --xpath "//table[@class='table table-primary table-forecast allSwellsActive msw-js-table msw-units-large']/tbody[1]/tr[contains(@class,'is-first')][$i]" - 2> /dev/null)
                t=$todaytablerow
                lineTime=$(echo $t | xmllint --html --xpath '//td[1]/small[1]/text()' - 2>/dev/null) # echo 6am
                lineSurf=$(echo $t | xmllint --html --xpath '//td[2]'        - 2>/dev/null | sed 's|</b>|-|g' | sed 's|<[^>]*>||g' | xargs | tr -s " ") # echo 0.5-0.8m    for surf
                lineSwel=$(echo $t | xmllint --html --xpath '//td[4]'        - 2>/dev/null | sed 's|</b>|-|g' | sed 's|<[^>]*>||g' | xargs | tr -s " ") # echo 0.5-0.8m    for swell
                linePeri=$(echo $t | xmllint --html --xpath '//td[5]'        - 2>/dev/null | sed 's|</b>|-|g' | sed 's|<[^>]*>||g' | xargs | tr -s " ") # echo 9s   as wave period
                lineTemp=$(echo $t | xmllint --html --xpath '//td[last()-1]' - 2>/dev/null | sed 's|</b>|-|g' | sed 's|<[^>]*>||g' | xargs | sed -e 's/Â//g' | sed -e 's/&Acirc;&deg;c/C/g' | sed -e 's/&Acirc;&deg;f/F/g' | sed -e 's/°c/C/g' | sed -e 's/°f/F/g' | tr -s " ") # echo 18C   as temperature
                lineWind=$(echo $t | xmllint --html --xpath '//td[last()-4]' - 2>/dev/null | sed 's|</b>|-|g' | sed 's|<[^>]*>||g' | xargs | tr -s " " | sed -e 's/ /-/' | sed -e 's/ //') # echo 22 34 kph   as wind
                line=$(echo -e "$line\n$lineTime\t$lineSurf\t$lineSwel\t$linePeri\t$lineWind\t$lineTemp")
            done
            todayconditions=$line
            if [ "$wavesnow" != "" ]; then
                echo "$wavesnow"
                echo "$weathernow"
                echo -e "$todayconditions" | column -t
                break
            else
                echo "retrying ..."
            fi
            x=$(($x + 1))
        done
        # echo "" # add newline
    fi
}

if [ "$#" == "0" ]; then
    echo "Example waves or surf locations are: bondi san-diego new-york san-fran"
    echo "Try \"waves gunnamatta\" for example to get the Gunnamatta, Melbourne, waves and surf forecast."
    exit 0
fi

arg1=$1 # waves-location, beach/city, required
arg2=$2 # "full" (optional) or "short" (optional) or "notorify" (optional) or empty
arg3=$3 # "notorify" or empty

#if [ "$arg2" == "" ]; then
#	arg2="1" # default, get only last item, if no number specified
#fi

if [ "$arg2" == "notorify" ] || [ "$arg3" == "notorify" ]; then
    TORIFY=""
    echo "Are you sure you do not want to use TOR?"
    if [ "$arg2" == "notorify" ]; then
        arg2="$arg3"
    fi
fi

function dowaves() {
    arg1="${1,,}"
    arg2="${2,,}"
    case "$arg1" in
    all)
        for city in san-francisco san-diego puerto-rico; do
            dowaves "$city" "$arg2"
            echo -e "\n\n\n"
        done
        ;;
    "${WAVES_DEFAULT_CITY1,,}" | "${WAVES_DEFAULT_CITY2,,}" | "${WAVES_DEFAULT_CITY3,,}")
        getwaves "${WAVES_DEFAULT_CITY1}" "$arg2"
        ;;
    bondi | sydney)
        getwaves "Sydney-Bondi-Surf-Report/996/" "$arg2"
        ;;
    e | eastbourne | england)
        getwaves "Eastbourne-Surf-Report/1325/" "$arg2"
        ;;
    g | m | gunnamatta | melbourne)
        getwaves "Gunnamatta-Surf-Report/535/" "$arg2"
        ;;
    ny | nyc | new-york | new-jersey)
        getwaves "New-Jersey-New-York-Surf-Forecast/22/" "$arg2"
        ;;
    p | pornic | ermitage | france)
        getwaves "LErmitage-Surf-Report/4410/" "$arg2" # France
        ;;
    pr | puerto-rico | san-juan)
        getwaves "Dunes-Puerto-Rico-Surf-Report/452/" "$arg2"
        ;;
    s | sylt | germany)
        getwaves "Sylt-Surf-Report/158/" "$arg2"
        ;;
    sd | san-diego)
        getwaves "Mission-Beach-San-Diego-Surf-Report/297/" "$arg2"
        ;;
    sf | san-fran | san-francisco)
        getwaves "Ocean-Beach-Surf-Report/255/" "$arg2"
        ;;
    u | urangan | hervey | hb | "75" | fraser | "fi")
        getwaves "Fraser-Island-Surf-Report/1002/" "$arg2"
        ;;
    *)
        getwaves "$arg1" "$arg2"
        ;;
    esac
}

dowaves "$arg1" "$arg2"

exit 0

# EOF
