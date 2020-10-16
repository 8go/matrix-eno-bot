#!/bin/sh -e

echo "
This is the bot help page:

Bot as personal assistent: bot commands provided:

- help: to list available bot commands
- echo: trivial example to have the bot respond, it echos
  back what is given to it
- hello: gives you a friendly compliment
- motd: gives you the Linux Message Of The Day
- ddg: search the web with DuckDuckGo search
- web: surf the web, get a web page (JavaScript not supported)
- rss: read RSS feeds
- twitter: read latest user tweets from Twitter
  (does not always work as info is scraped from web,
  currently it seems to be always down)
- totp: get 2FA Two-factor-authentication TOTP PIN via bot message
- hn: read Hacker News, fetches front page headlines from Hacker News
- mn: read Messari News, fetches the latest news articles from Messari
- date: gives date and time
- weather: gives weather forecast
- tides: give tidal forecast
- waves: give waves and surf forecast
- btc: gives Bitcoin BTC price info
- eth: gives Ethereum price info
- s2f: gives Stock-to-flow info

Bot as admin tool: bot commands provided to Matrix or system administrators

With these commands a system administrator can maintain
a Matrix installation and keep a watchful eye on the
server all through the Matrix bot.

- backup: performs backup on server
- users: list registered Matrix users
- disks: see how full your disks or mountpoints are
- cputemp: monitor the CPU temperatures
- restart: restart the bot itself, or Matrix services
- wake: wake up another PC via LAN
- check: check status, health status, updates, etc.
  of bot, Matrix and the operating system
- update: update operating sytem
- firewall: list the firewall settings and configuration
- date: gives date and time of server
- platform: gives hardware and operating system platform information
- ps: print current CPU, RAM and Disk utilization of server
- top: gives 5 top CPU and RAM consuming processes
- alert: shows if any CPU, RAM, or disk thresholds have been exceeded
  (best to combine with a cron job, and have the cron job
  send the bot message to Matrix admin rooms)
"

# EOF
