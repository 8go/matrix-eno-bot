#!/bin/bash

# use TORIFY or TORPROXY, but do NOT use BOTH of them!
# TORIFY="torify"
TORIFY="" # replaced with TORPROXY, dont use both
TORPROXY=" --tor "

# tor and torify should be installed for your privacy.
type torify >/dev/null 2>&1 || {
    echo "It is recommended that you install the packge \"tor\" on the server for privacy."
    TORIFY=""
    TORPROXY=""
}

# use either rsstail or rssread.py, one or the other

# A copy of rssread.py can be found in the same repo, same directory, as this rss.sh script.
type rssread.py >/dev/null 2>&1 || {
    # it was not found in normal path, lets see if we can  amplify the PATH by sourcing profile files
    . $HOME/.bash_profile 2>/dev/null
    . $HOME/.profile 2>/dev/null
    type rssread.py >/dev/null 2>&1 || {
        echo "This script requires that you install the script \"rssread.py\" and its dependencies on the server."
        exit 0
    }
}

# alternatively rsstail must be installed
# rsstail must be installed
# If you use rsstail, uncomment the following lines
# type rsstail >/dev/null 2>&1 || {
#    echo "This script requires that you install the packge \"rsstail\" on the server."
#    exit 0
# }

function readrss() {
    if [ "$2" == "" ]; then
        echo "Fetching todays's items from feed \"$1\"..."
    else
        echo "Fetching latest $2 items from feed \"$1\"..."
    fi
    # if there 3 newlines, it will generate separate posts, but it is nicer and easier to remove later if everything is nicely bundled into 1 post
    # so, first we use sed to remove all occurances of 5, 4, and 3 newlines.
    # Then we insert 2 newlines after the last newline to create 3 newlines, so that at the end of the feed item the Matrix message is split.
    # This way N feed posts always create exactly N Matrix messages.
    # Inserting newlines with sed: https://unix.stackexchange.com/questions/429139/replace-newlines-with-sed-a-la-tr

    # shellcheck disable=SC2086
    $TORIFY rssread.py $TORPROXY --feed "$1" --number $2 | sed 'H;1h;$!d;x; s/\n\n\n\n\n/\n\n/g' | sed 'H;1h;$!d;x; s/\n\n\n\n/\n\n/g' |
        sed 'H;1h;$!d;x; s/\n\n\n/\n\n/g' | sed '/Pub.date: /a \\n\n' # add newlines for separation after last line

    # alternatively: rsstail
    # If you use rsstail, uncomment these lines, and comment the above lines withe rssread.py
    # $TORIFY rsstail -1 -ldpazPH -u "$1" -n $2 | sed 'H;1h;$!d;x; s/\n\n\n\n\n/\n\n/g' | sed 'H;1h;$!d;x; s/\n\n\n\n/\n\n/g' | \
    #   sed 'H;1h;$!d;x; s/\n\n\n/\n\n/g' | sed '/Pub.date: /a \\n\n' # add newlines for separation after last line
}

if [ "$#" == "0" ]; then
    echo -n "Currently supported feeds are: "
    echo "all, affaires, andreas, ars1, ars2, ars3, btc, coin, citron, core, futura, hn, jimmy, matrix, noon, pine, qubes, trezor"
    echo "Try \"rss pine 2\" for example to get the latest 2 news items from Pine64.org News RSS feed."
    exit 0
fi

arg1=$1 # rss feed, required
arg2=$2 # number of items (optional) or "notorify"
arg3=$3 # "notorify" or empty

if [ "$arg2" == "" ]; then
    # arg2="1" # default, get only last item, if no number specified  # rsstail
    arg2="" # default, get today's items, if no number specified  ## rssread.py
fi

if [ "$arg2" == "notorify" ] || [ "$arg3" == "notorify" ] || [ "$arg2" == "notor" ] || [ "$arg3" == "notor" ]; then
    TORIFY=""
    TORPROXY=""
    echo "Are you sure you do not want to use TOR?"
    if [ "$arg2" == "notorify" ] || [ "$arg2" == "notor" ]; then
        # arg2="1"  # rsstail
        arg2="" # rssread.py, get today's items
    fi
fi

case "$arg2" in
*[!0-9]*)
    echo "Second argument is not a number. Skipping. Try \"rss pine 1\"."
    exit 0
    ;;
*)
    # echo "First argument is a number. "
    ;;
esac

function dofeed() {
    arg1="$1"
    arg2="$2"
    case "$arg1" in
    all)
        for feed in affaires andreas ars1 ars2 ars3 btc citron coin core futura jimmy matrix noon pine qubes trezor; do
            dofeed "$feed" "$arg2"
            echo -e "\n\n\n"
        done
        ;;
    affaires)
        readrss "https://www.lesaffaires.com/rss/techno/internet" "$arg2"
        ;;
    andreasm)
        readrss "https://medium.com/feed/@aantonop" "$arg2"
        ;;
    andreas)
        readrss "https://twitrss.me/twitter_user_to_rss/?user=aantonop" "$arg2"
        ;;
    ars1)
        readrss "http://feeds.arstechnica.com/arstechnica/technology-lab" "$arg2"
        ;;
    ars2)
        readrss "http://feeds.arstechnica.com/arstechnica/features" "$arg2"
        ;;
    ars3)
        readrss "http://feeds.arstechnica.com/arstechnica/gadgets" "$arg2"
        ;;
    btc)
        readrss "https://bitcoin.org/en/rss/blog.xml" "$arg2"
        ;;
    citron)
        TORIFYBEFORE=$TORIFY     # temporarily turn TORIFY off because citron does not work under TOR
        TORPROXYBEFORE=$TORPROXY # temporarily turn TORPROXY off because citron does not work under TOR
        TORIFY=""
        TORPROXY=""
        readrss "https://www.presse-citron.net/feed/" "$arg2"
        TORIFY=$TORIFYBEFORE
        TORPROXY=$TORPROXYBEFORE
        ;;
    coin)
        readrss "https://www.coindesk.com/feed?x=1" "$arg2"
        ;;
    core)
        readrss "https://bitcoincore.org/en/rss.xml" "$arg2"
        ;;
    futura)
        # readrss "https://www.futura-sciences.com/rss/actualites.xml" "$arg2"
        readrss "https://www.futura-sciences.com/rss/high-tech/actualites.xml" "$arg2"
        ;;
    hn)
        readrss "https://hnrss.org/frontpage" "$arg2"
        ;;
    jimmy)
        readrss "https://medium.com/feed/@jimmysong" "$arg2"
        ;;
    matrix)
        readrss "https://matrix.org/blog/feed/" "$arg2"
        ;;
    noon)
        readrss "https://hackernoon.com/feed" "$arg2"
        ;;
    nobs)
        readrss "http://rss.nobsbtc.com" "$arg2"
        ;;
    pine)
        readrss "https://www.pine64.org/feed/" "$arg2"
        ;;
    qubes)
        readrss "https://www.qubes-os.org/feed.xml" "$arg2"
        ;;
    trezor)
        readrss "https://blog.trezor.io/feed/" "$arg2"
        ;;
    *)
        echo "This feed is not configured on server."
        ;;
    esac
}

dofeed "$arg1" "$arg2"

exit 0

# EOF
