#!/usr/bin/python3
"""Read and parse RSS feeds."""

# Don't change tabbing, spacing, formating as file is automatically linted.
# isort rssread.py
# flake8 rssread.py
# python3 -m black rssread.py

# forked from source: https://github.com/sathwikv143/rssNews

# command line options: see: rssread.py --help
# get the post from today
# example: rssread.py --feed "https://hnrss.org/frontpage" --today
# get the post from yesterday
# example: rssread.py --feed "https://hnrss.org/frontpage" --yesterday
# get last 3 posts
# example: rssread.py -feed "https://hnrss.org/frontpage" --number 3
# example: rssread.py -feed https://feed1.io https://feed2.com --today -n 10
# example: rssread.py -f http://feed.com -b 2021-02-20 -e 2021-02-20 -n 1000

# install dependencies: e.g. similar to:
# pip3 install --user --upgrade feedparser
# pip3 install --user --upgrade fuzzywuzzy
# pip3 install --user --upgrade python-Levenshtein
# pip3 install --user --upgrade python-dateutil

import argparse
import logging
import os
import re
import sys
import textwrap
import traceback
from datetime import date, timedelta

import feedparser
import requests
from dateutil import parser
from fuzzywuzzy import fuzz

DEFAULT_SEPARATOR = ""
DEFAULT_NUMBER = 3


def display_news(title, summary, summary_detail, content, link, pubDate):  # noqa
    """Display the Parsed News."""
    # print(79*"=")
    if not args.no_title:
        print("Title: " + title)
    if not args.no_summary:
        for line in textwrap.wrap(summary, width=79):
            print(line)
        # if summary != "":
        #    print("")
    if not args.no_summary_detail:
        for line in textwrap.wrap(summary_detail, width=79):
            print(line)
        # if summary_detail != "":
        #    print("")
    if not args.no_content:
        for line in textwrap.wrap(content, width=79):
            print(line)
        # if content != "":
        #    print("")
    if not args.no_link:
        print("Link: " + link)
    if not args.no_date:
        print("Pub.date: " + pubDate)
    if args.separator != "":
        print(args.separator.replace("\\n", "\n"), end="")


def get_date(entries):
    """Get the date published of an Entry."""
    dop = entries["published"]
    dop_to_date = parser.parse(dop, ignoretz=True)
    dop_date = dop_to_date.date()
    logger.debug(f"published: {dop} and {dop_to_date}")
    return dop_date


def get_news_entry(entry, proxyindicator):  # noqa
    """Get the title, link and summary of one news item."""
    try:
        title = entry["title"]
    except Exception:
        title = "Unknown"
        pass
    try:
        link = entry["link"]
    except Exception:
        link = ""
        pass
    try:
        summary_raw = re.sub("<[^<]+?>", " ", str(entry["summary"]).replace("\n", " "),)
        summary = "Summary: " + summary_raw
        summary = " ".join(summary.split())  # collapse multiple spaces
    except Exception:
        summary_raw = ""
        summary = ""
        pass
    try:
        summary_detail_raw = "Summary Detail: " + re.sub(
            "<[^<]+?>", " ", str(entry["summary_detail"]).replace("\n", " "),
        )
        summary_detail = "Summary Detail: " + summary_detail_raw
        # collapse multiple spaces into a single space
        summary_detail = " ".join(summary_detail.split())
    except Exception:
        summary_detail_raw = ""
        summary_detail = ""
        pass
    try:
        content = "Content: " + re.sub("<[^<]+?>", " ", str(entry["content"]))
        # collapse multiple spaces into a single space
        content = " ".join(content.split())
    except Exception:
        content = ""
        if "DEBUG" in os.environ:
            pass  # print stacktrace
    try:
        pubDate = entry["published"]
    except Exception:
        pubDate = ""
        pass
    if content.find(summary_raw) == -1:
        if "DEBUG" in os.environ:
            print("Summary_detail and content are different!")
        if fuzz.partial_ratio(summary_raw, content) > 90:
            if "DEBUG" in os.environ:
                print("Summary_detail and content are very similar!")
            content = ""  # content is more or less a copy of summary
    else:
        content = ""  # content is just a copy of summary
    if len(summary_raw) > 10000:
        # if the summary is so big (10K+) I don't care about the
        # details anymore
        summary_detail = ""
    elif summary_detail_raw.find(summary_raw) == -1:
        if "DEBUG" in os.environ:
            print("Summary_detail and summary are different!")
            print(f"Sizes are {len(summary_detail_raw)} " f"and {len(summary_raw)}.")
        if len(summary_detail_raw) > 10000 and len(summary_raw) > 10000:
            if (
                abs(len(summary_detail_raw) - len(summary_raw))
                / max(len(summary_detail_raw), len(summary_raw))
                < 0.15
            ):
                # summary_detail is more or less a copy of summary
                summary_detail = ""
        else:
            if (
                fuzz.partial_ratio(summary_detail_raw, summary_raw) > 90
            ):  # this blows up for large text (20K+)
                if "DEBUG" in os.environ:
                    print("Summary_detail and summary are very similar!")
                # summary_detail is more or less a copy of summary
                summary_detail = ""
    else:
        summary_detail = ""  # summary_detail is just a copy of summary
    display_news(
        title + proxyindicator, summary, summary_detail, content, link, pubDate
    )


def get_news(entries, noe, fromday, uptoday, parsed_url, proxyindicator):
    """Get the title, link and summary of the news."""
    for i in range(0, noe):
        logger.debug(f"Entry:: {entries[i]}")
        dop_date = get_date(entries[i])
        if dop_date >= fromday and dop_date <= uptoday:
            get_news_entry(entries[i], proxyindicator)


def parse_url(urls, noe, fromday, uptoday):
    """Parse the URLs with feedparser."""
    if args.tor:
        if os.name == "nt":
            TOR_PORT = 9150  # Windows
        else:
            TOR_PORT = 9050  # LINUX
        proxies = {
            "http": f"socks5://127.0.0.1:{TOR_PORT}",
            "https": f"socks5://127.0.0.1:{TOR_PORT}",
        }
        proxyindicator = " [via Tor]"
    else:
        proxies = {}
        proxyindicator = ""

    logger.debug(f"Proxy is: {proxies}{proxyindicator}")

    for url in urls:
        # feedparser does NOT support PROXY or Tor
        # but it does support files or strings, so we
        # load the URL into a string
        logger.debug(f"URL is: {url}")
        cont = requests.get(url, proxies=proxies)
        logger.debug(f"cont is: {cont}")
        if args.verbose:
            logger.debug(f"cont is: {cont.content}")
        parsed_url = feedparser.parse(cont.content)
        entries = parsed_url.entries
        max = len(entries)
        noe = min(noe, max)
        get_news(entries, noe, fromday, uptoday, parsed_url, proxyindicator)


# main
if __name__ == "__main__":  # noqa
    logging.basicConfig()  # initialize root logger, a must
    if "DEBUG" in os.environ:
        logging.getLogger().setLevel(logging.DEBUG)  # set root logger log level
    else:
        logging.getLogger().setLevel(logging.INFO)  # set root logger log level

    # Construct the argument parser
    ap = argparse.ArgumentParser(description="This program reads news from RSS feeds.")
    # Add the arguments to the parser
    ap.add_argument(
        "-d",
        "--debug",
        required=False,
        action="store_true",
        help="Print debug information.",
    )
    ap.add_argument(
        "-v",
        "--verbose",
        required=False,
        action="store_true",
        help="Print verbose output.",
    )
    ap.add_argument(
        "-f",  # feed
        "--feed",
        required=True,
        type=str,
        nargs="+",
        help="Specify RSS feed URL. E.g. --feed https://hnrss.org/frontpage.",
    )
    ap.add_argument(
        "-o",  # onion
        "--tor",
        required=False,
        action="store_true",
        help="Use Tor, go through Tor Socks5 proxy.",
    )
    ap.add_argument(
        "-t",  # today
        "--today",
        required=False,
        action="store_true",
        help="Get today's entries from RSS feed.",
    )
    ap.add_argument(
        "-y",  # yesterday
        "--yesterday",
        required=False,
        action="store_true",
        help="Get yesterday's entries from RSS feed",
    )
    ap.add_argument(
        "-n",  # number
        "--number",
        required=False,
        type=int,
        default=DEFAULT_NUMBER,
        help=(
            "Number of last entries to get from from RSS feed. "
            f'Default is "{DEFAULT_NUMBER}".'
        ),
    )
    ap.add_argument(
        "-b",  # beginning
        "--from-day",
        required=False,
        type=str,
        help=(
            "Specify a 'from' date, i.e. an earliest day allowed. "
            "Specify in format YYYY-MM-DD such as 2021-02-25."
        ),
    )
    ap.add_argument(
        "-e",  # end
        "--to-day",
        required=False,
        type=str,
        help=(
            "Specify a 'to' date, i.e. a latest day allowed. "
            "Specify in format YYYY-MM-DD such as 2021-02-26."
        ),
    )
    ap.add_argument(
        "-s",  # separator
        "--separator",
        required=False,
        type=str,
        default=DEFAULT_SEPARATOR,
        help=(
            "Specify a separator to be printed after each RSS entry. "
            f'Default is "{DEFAULT_SEPARATOR}". '
            'E.g. use "\\n" to print an empty line. '
            'Or use "==================\\n" to print a dashed line. '
            'Note that letters like "-" or "newline" might need to be '
            'escaped like "\\-" or "\\n".'
        ),
    )
    ap.add_argument(
        "--no-title",
        required=False,
        action="store_true",
        help=(
            'Don\'t print the "Title" record of the RSS entry. This is '
            "useful for example for feeds where the title is just a "
            "repetition of the first words of the summary. "
        ),
    )
    ap.add_argument(
        "--no-summary",
        required=False,
        action="store_true",
        help='Don\'t print the "Summary" record of the RSS entry.',
    )
    ap.add_argument(
        "--no-summary-detail",
        required=False,
        action="store_true",
        help='Don\'t print the "Summary Detail" record of the RSS entry.',
    )
    ap.add_argument(
        "--no-content",
        required=False,
        action="store_true",
        help='Don\'t print the "Content" record of the RSS entry.',
    )
    ap.add_argument(
        "--no-link",
        required=False,
        action="store_true",
        help='Don\'t print the "Link" record of the RSS entry.',
    )
    ap.add_argument(
        "--no-date",
        required=False,
        action="store_true",
        help='Don\'t print the "Publish Date" record of the RSS entry.',
    )
    args = ap.parse_args()
    if args.debug:
        logging.getLogger().setLevel(logging.DEBUG)  # set root logger log level
        logging.getLogger().info("Debugging is turned on.")
    logger = logging.getLogger("readrss")
    # logging.getLogger().info("Debug is turned on.")

    # Get Dates of Present and Previous Day's
    today = date.today()
    yesterday = today - timedelta(1)
    ayearago = today - timedelta(365)

    noe = args.number  # initialize
    fromday = ayearago
    uptoday = today
    if args.today:
        fromday = today  # all entries of today
    if args.yesterday:
        fromday = yesterday  # all entries of yesterday
        uptoday = yesterday

    if args.from_day:
        fromday = date.fromisoformat(args.from_day)
    if args.to_day:
        uptoday = date.fromisoformat(args.to_day)

    logger.debug(f"feed(s): {args.feed}")
    logger.debug(f"number: {noe}")
    logger.debug(f"from day: {fromday}")
    logger.debug(f"up to day: {uptoday}")

    try:
        parse_url(args.feed, noe, fromday, uptoday)
    except requests.exceptions.ConnectionError as e:
        if args.tor:
            print(
                f"ConnectionError: Maybe Tor is not running. ({e})", file=sys.stderr,
            )
        else:
            print(
                "ConnectionError: " f"Maybe network connection is not down. ({e})",
                file=sys.stderr,
            )
        sys.exit(1)
    except Exception:
        traceback.print_exc(file=sys.stdout)
        sys.exit(1)
    except KeyboardInterrupt:
        sys.exit(1)

# EOF
