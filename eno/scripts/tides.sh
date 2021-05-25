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
function gettide() {
    if [[ "$1" == "" ]]; then
        echo "No tides report for empty location. Set location."
        return
    fi
    if [[ "$2" == "full" ]] || [[ "$2" == "f" ]] || [[ "$2" == "more" ]] || [[ "$2" == "+" ]]; then
        # give a full, long listing of forecast
        echo "To be implemented" # to be implemented
    elif [[ "$2" == "short" ]] || [[ "$2" == "less" ]] || [[ "$2" == "s" ]] || [[ "$2" == "l" ]] || [[ "$2" == "-" ]]; then
        # give a short, terse listing of forecast
        echo "To be implemented" # to be implemented
    else
        # give a mediaum, default listing of tides, just today
        echo "${1^}: "
        #old code: they changed web layout, so it broke
        #xmllint --html --xpath '//table[@class = "tide-times__table--table"]/tbody/tr/td' - 2>/dev/null | \
        #sed "s|<td><b>| |g" | sed "s|</b></td>| |g" | sed "s|<span class=\"today__tide-times--nextrow\">| |g" | \
        #sed "s|</span>| |g" | sed 's|<td class="js-two-units-length-value" data-units="Imperial"><b class="js-two-units-length-value__primary">| |g' | \
        #sed 's|</b><span class="today__tide-times--nextrow js-two-units-length-value__secondary">| |g' | \
        #sed 's|<td class="js-two-units-length-value" data-units="Metric">| |g' | \
        #sed 's|<b class="js-two-units-length-value__primary">| |g' | \
        #sed "s|</td>||g" | tr -d '\n' | sed "s|Low Tide|\nLow  Tide|g" | sed "s|High Tide|\nHigh Tide|g" | \
        #sed 's|([^)]*)||g' | sed 's|     |  |g' | sed 's| Tide  | |g' | sed 's|m   |m|g' | sed 's| m|m|g'

        x=1
        while [ $x -le 10 ]; do
            # shellcheck disable=SC2086
            res=$($TORIFY wget -q -O - https://www.tide-forecast.com/locations/${1}/tides/latest |
                xmllint --html --xpath '//table[@class = "tide-day-tides"]/tr/td' - 2>/dev/null | head -n 12 | sed 'N;N;s/\n/ /g' | sed -e 's/<[^<>]*>//g' |
                sed -e 's/Low Tide/Low Tide /g' | sed -e 's/([^()]*ft)//g' | sed -e 's/ m $/m/g' | sed -e 's/(/ (/g')
            if [ "$res" != "" ]; then
                echo "$res"
                break
            else
                echo "retrying ..."
            fi
            # get 4 values (each value has 3 lines), so get 12 lines, any large number could be got, even 30, maybe even 60
            # sed 'N;N;s/\n/ /g'  ... combine lines 1, 2 and 3. 4, 5 and 6. etc
            # sed -e 's/<[^<>]*>//g' ... remove everything that is between <...>, i.e. remove the HTML tags
            # sed -e 's/([^()]*ft)//g' ... remove the '(3.45 ft)' data
            x=$(($x + 1))
        done
        echo "" # add newline
    fi
}

if [ "$#" == "0" ]; then
    echo "Example tide locations are: hamburg san-diego new-york san-fran"
    echo "Try \"tide hamburg\" for example to get the Hamburg tide forecast."
    exit 0
fi

arg1=$1 # tide-location, city, required
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

function dotide() {
    arg1="${1,,}"
    arg2="${2,,}"
    case "$arg1" in
    all)
        for city in san-francisco san-diego lima; do
            dotide "$city" "$arg2"
            echo -e "\n\n\n"
        done
        ;;
    "${TIDES_DEFAULT_CITY1,,}" | "${TIDES_DEFAULT_CITY2,,}" | "${TIDES_DEFAULT_CITY3,,}")
        gettide "${TIDES_DEFAULT_CITY1}" "$arg2"
        ;;
    h | hamburg)
        gettide "Hamburg-Germany" "$arg2"
        ;;
    l | london)
        gettide "London-Bridge-England" "$arg2"
        ;;
    m | melbourne)
        gettide "Melbourne-Australia" "$arg2"
        ;;
    ny | nyc | new-york)
        gettide "New-York-New-York" "$arg2"
        ;;
    p | pornic)
        gettide "Pornic" "$arg2" # France
        ;;
    sd | san-diego)
        gettide "San-Diego-California" "$arg2"
        ;;
    sf | san-fran | san-francisco)
        gettide "San-Francisco-California" "$arg2"
        ;;
    u | urangan | hervey | hb | fraser | "75" | "fi")
        gettide "Urangan-Australia" "$arg2"
        ;;
    *)
        gettide "$arg1" "$arg2"
        ;;
    esac
}

dotide "$arg1" "$arg2"

exit 0

# EOF
