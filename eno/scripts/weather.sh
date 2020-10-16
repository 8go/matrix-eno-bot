#!/bin/bash

TORIFY="torify"

# tor and torify should be installed for your privacy.
type torify >/dev/null 2>&1 || {
    echo "It is recommended that you install the packge \"tor\" on the server for privacy."
    TORIFY=""
}

# ansiweather must be installed
type ansiweather >/dev/null 2>&1 || {
    # see: https://github.com/fcambus/ansiweather
    echo "This script requires that you install the packge \"ansiweather\" on the server."
    exit 0
}

if [ -f "$(dirname "$0")/config.rc" ]; then
    [ "$DEBUG" == "1" ] && echo "Sourcing $(dirname "$0")/config.rc"
    # shellcheck disable=SC1090
    source "$(dirname "$0")/config.rc" # if it exists, optional, not needed, allows to set env variables
fi

# $1: location, city
# $2: optional, "full" for more details
function getweather() {
    # if $1 is "" then it will get weather for local location based on IP address
    if [[ "$2" == "full" ]] || [[ "$2" == "f" ]] || [[ "$2" == "more" ]] || [[ "$2" == "+" ]]; then
        # give a full, long listing of forecast
        torify curl "wttr.in/${1%,*}?m" # remove everything to the right of comma
    elif [[ "$2" == "short" ]] || [[ "$2" == "less" ]] || [[ "$2" == "s" ]] || [[ "$2" == "l" ]] || [[ "$2" == "-" ]]; then
        # give a short, terse listing of forecast
        torify curl "wttr.in/${1%,*}?m&format=%l:+%C+%t+(%f)+%o+%p" # remove everything to the right of comma
    else
        # give a mediaum, default listing of forecast
        if [ "${1,,}" == "san+juan,puerto+rico" ]; then set -- "4568138"; fi # bug, reset $1
        # see https://openweathermap.org/city/4568138
        $TORIFY ansiweather -l "$1" | tr "-" "\n" | tr "=>" "\n" | sed "s/^ //g" | sed '/^[[:space:]]*$/d' 2>&1
    fi
}

if [ "$#" == "0" ]; then
    echo "Example weather locations are: paris london san-diego new-york"
    echo "Try \"weather melbourne\" for example to get the Melbourne weather forecast."
    echo "Try \"weather France\" for example to get the French weather forecast."
    echo "Try \"weather New+York,US\" for example to get the NYC weather forecast."
    echo "Try \"weather all\" for a selection of weather forecasts."
    exit 0
fi

arg1=$1 # tweather-location, city, required
arg2=$2 # "full" (optional) or "short" (optional) or "notorify" (optional) or empty
arg3=$3 # "notorify" or empty

#if [ "$arg2" == "" ]; then
#       arg2="1" # default, get only last item, if no number specified
#fi

if [ "$arg2" == "notorify" ] || [ "$arg3" == "notorify" ]; then
    TORIFY=""
    echo "Are you sure you do not want to use TOR?"
    if [ "$arg2" == "notorify" ]; then
        arg2="$arg3"
    fi
fi

function doweather() {
    arg1="${1,,}"
    arg2="${2,,}"
    case "$arg1" in
    all)
        doweather "san-francisco" "$arg2"
        for city in san-diego vacaville lima,pe madrid,es San+Juan,Puerto+Rico; do
            echo "------------------------------"
            doweather "$city" "$arg2"
        done
        ;;
    "${WEATHER_DEFAULT_CITY1,,}" | "${WEATHER_DEFAULT_CITY2,,}" | "${WEATHER_DEFAULT_CITY3,,}")
        getweather "${WEATHER_DEFAULT_CITY1}" "$arg2"
        ;;
    bi | bilbao)
        getweather "Bilbao,ES" "$arg2"
        ;;
    l | lima)
        getweather "Lima,PE" "$arg2"
        ;;
    lo | london)
        getweather "London,GB" "$arg2"
        ;;
    m | melbourne)
        getweather "Melbourne,AU" "$arg2"
        ;;
    ny | nyc | new-york)
        getweather "New+York,US" "$arg2"
        ;;
    p | paris)
        getweather "Paris,FR" "$arg2"
        ;;
    pr | puertorico)
        getweather "San+Juan,Puerto+Rico" "$arg2"
        ;;
    sd | san-diego)
        getweather "San+Diego,US" "$arg2"
        ;;
    sf | san-fran | san-francisco)
        getweather "San+Francisco,US" "$arg2"
        ;;
    sk | st-kilda)
        getweather "St+Kilda,AU" "$arg2"
        ;;
    u | urangan | hervey | hb) # https://openweathermap.org/city/2146219
        getweather "Torquay,AU" "$arg2"
        ;;
    v | vacaville)
        getweather "Vacaville,US" "$arg2"
        ;;
    w | vienna)
        getweather "Vienna,AT" "$arg2"
        ;;
    *)
        getweather "$arg1" "$arg2"
        ;;
    esac
}

doweather "$arg1" "$arg2"

exit 0

# EOF
