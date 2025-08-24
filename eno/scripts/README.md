![matrix-eno-bot icon](../logos/eno-logo.svg)

This is te scripts directory of the `eno` bot. Most current scripts are `bash`, one is `Python3`.
But these could be any scripts or programs in any language from `JavaScript` to `Go`.

If you want to separate certain private variables (e.g. password hashes) from the scripts for security reasons, then have a look at the file `config.rc.example`. This is an optional file used (if available) by some scripts.

A short desription of each provided script follows. But add your own scripts to improve your own bot!

## Bot as Personal Assistant: Example bot commands provided

Commands useful to average users:

- btc: gives Bitcoin BTC price info
- ddg: search the web with DuckDuckGo search
- eth: gives Ethereum price info
- hello: gives you a friendly compliment
- help: to list available bot commands
- hn: read Hacker News, fetches front page headlines from Hacker News
- mn: read Messari News, fetches the latest news articles from Messari
- motd: gives you the Linux Message Of The Day
- rss: read RSS feeds
- s2f: print Bitcoin Stock-to-flow price info
- tides: get today's low and high tides of your favorite beach
- totp: get 2FA Two-factor-authentication TOTP One-Time-Password PIN via bot message (like Google Authenticator)
- twitter: read latest user tweets from Twitter (does **not** work most of the time as info is scraped from web)
- waves: get the surf report of your favorite beach
- weather: get the weather forecast for your favorite city
- web: surf the web, get a web page (JavaScript not supported)

## Bot as Admin Tool: Example bot commands provided to Matrix or system administrators

With these commands a system administrator can maintain his Matrix installation and keep a watchful eye on his server all through the Matrix bot. Set the permissions accordingly in the config file to avoid unauthorized use of these bot commands!

- alert: shows if any CPU, RAM, or Disk thresholds have been exceeded (best to combine with a cron job, and have the cron job send the bot message to Matrix admin rooms)
- backup: runs your backup script to backup files, partitions, etc.
- check: check status, health status, updates, etc. of bot, Matrix and the operating system
- cputemp: monitor the CPU temperatures
- date: gives date and time of server
- disks: see how full your disks or mountpoints are
- firewall: list the firewall settings and configuration
- platform: gives hardware and operating system platform information
- ps: print current CPU, RAM and Disk utilization of server
- restart: restart the bot itself, or Matrix services
- top: gives 5 top CPU and RAM consuming processes
- update: update operating sytem and other software environments
- users: list user accounts that exist on your server
- wake: wake up other PCs on the network via wake-on-LAN

