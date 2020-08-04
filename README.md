TODO: This bot is not ready yet. Please come back in 1-2 weeks! Thank you!

# matrix-eno-bot

![matrix-eno-bot icon](https://upload.wikimedia.org/wikipedia/commons/3/37/Nsibidi.png)

`matrix-eno-bot` is a [Matrix](https://matrix.org) bot based on the Python 3 bot template [nio-template](https://github.com/8go/nio-template) which in turn is based on the Matrix Python SDK called [matrix-nio](https://github.com/poljar/matrix-nio). The bot, the template and the SDK are all written in Python 3. The commands that the `matrix-eno-bot` comes with are written in `bash` and in `python3`.

## Naming: Eno?
Why `eno`? It is a word play. Yes, another word play. `Matrix` is a word play on the [Matrix movies](https://en.wikipedia.org/wiki/The_Matrix_(franchise)). `matrix-nio` one would guess is a word play on the character [Neo](https://en.wikipedia.org/wiki/Neo_(The_Matrix)), in the Matrix movies. Both `Neo` and `nio` sound the same. They are [homophones](https://en.wikipedia.org/wiki/Homophone). And `eno` is just a randomized version of `Neo`, an [anagram](https://en.wikipedia.org/wiki/Anagram) of Neo.

Eno is also another name for the [Ibibio tribe](https://en.wikipedia.org/wiki/Ibibio_people) in Nigeria. Hence, the "logo" which is nothing more than 3 Nsibidi symbols taken from [Wikipedia](https://en.wikipedia.org/wiki/Ibibio_people). 

And a month after creating this repo by pure chance, this [Urban Dictionary link](https://www.urbandictionary.com/define.php?term=Eno) for `eno` popped up. Here, the word `eno` is defined as: _Totally awesome, Wicked cool. Hyperbole of awesome/cool. E.g. Dude, that round of speedball was so eno!_ What a fitting coincidence! Perfect fit! So cool, oops, so eno!

## History and Past

The first version of the bot was [tiny-matrix-bot plus](https://github.com/8go/tiny-matrix-bot) which was based on [matrix-python-sdk](https://github.com/matrix-org/matrix-python-sdk). Since `matrix-python-sdk` is no longer actively supported and end-to-end-encryption comes out of the box in `matrix-nio`, the switch to `nio-template` was made. 

## Installation and Setup

TODO: This needs to be re-written. Not correct currently.

```
sudo apt install python3 python3-requests
git clone https://github.com/8go/tiny-matrix-bot
git clone https://github.com/matrix-org/matrix-python-sdk
cd tiny-matrix-bot
ln -s ../matrix-python-sdk/matrix_client
cp tiny-matrix-bot.cfg.sample tiny-matrix-bot.cfg
vim tiny-matrix-bot.cfg # adjust the config file, add token, etc.
cp tiny-matrix-bot.service /etc/systemd/system
vim /etc/systemd/system/tiny-matrix-bot.service # adjust service to your setup
systemctl enable tiny-matrix-bot
systemctl start tiny-matrix-bot
systemctl stop tiny-matrix-bot
```

## Usage

TODO: This needs to be revised.

- intended audience/users: 
  - small homeserver set up for a few friends
  - tinkerers who want to learn how a bot works
  - people who want to play around with Python code and Matrix
- create a Matrix account for the bot, name it `bot` for example
- configure the bot software
- create the bot service and start the bot or the bot service
- log in to the before created Matrix `bot` account e.g. via Riot web page
- manually send invite from `bot` account to a friend (or to yourself)
- once invite is accepted, reset the bot service (so that the new room will be added to bot service)
  - if you as admin already have a room with the bot, you can reset the bot by sending it `restart bot` as a message in your Matrix bot room
- have the newly joined invitee send a `hello` command to the bot for a first test
- bot can handle encrypted rooms by default

## Debugging

TODO: This needs to be revised. Not correct at the moment.

Run something similar to
```
systemctl stop tiny-matrix-bot # stop server in case it is running
cd tiny-matrix-bot # go to your installation directory
./tiny-matrix-bot.py --debug # observe debug output
```

## Bot as Personal Assistant: Example bot commands provided

- help: to list available bot commands
- ping: trivial example to have the bot respond
- pong: like ping, but pong
- hello: gives you a friendly compliment
- motd: gives you the Linux Message Of The Day
- ddg: search the web with DuckDuckGo search
- web: surf the web, get a web page (JavaScript not supported)
- tides: get today's low and high tides of your favorite beach
- weather: get the weather forecast for your favorite city
- rss: read RSS feeds
- twitter: read latest user tweets from Twitter (does not always work as info is scraped from web)
- tesla: chat with your Tesla car (dummy)
- totp: get 2FA Two-factor-authentication TOTP PIN via bot message
- hn: read Hacker News, fetches front page headlines from Hacker News
- mn: read Messari News, fetches the latest news articles from Messari
- date: gives date and time
- btc: gives Bitcoin BTC price info
- eth: gives Ethereum price info
- s2f: print Bitcoin Stock-to-flow price info

## Bot as Admin Tool: Example bot commands provided to Matrix or system administrators

With these commands a system administrator can maintain his Matrix installation and keep a watchful eye on his server all through the Matrix bot. Set the permissions accordingly in the config file to avoid unauthorized use of these bot commands!

- disks: see how full your disks or mountpoints are
- cputemp: monitor the CPU temperatures
- restart: restart the bot itself, or Matrix services
- check: check status, health status, updates, etc. of bot, Matrix and the operating system
- update: update operating sytem
- wake: wake up other PCs on the network via wake-on-LAN
- firewall: list the firewall settings and configuration
- date: gives date and time of server
- platform: gives hardware and operating system platform information
- ps: print current CPU, RAM and Disk utilization of server
- top: gives 5 top CPU and RAM consuming processes
- alert: shows if any CPU, RAM, or Disk thresholds have been exceeded (best to combine with a cron job, and have the cron job send the bot message to Matrix admin rooms)

## Other Features

TODO: This needs to be revised. Not correct currently. 

- bot can also be used as an CLI app to send messages to rooms where bot is a member
- when sending messages, 3 message formats are supported:
  - text: by default
  - html: like using `/html ...` in a chat
  - code: for sending code snippets or script outputs, like `/html <pre><code> ... </code></pre>`
- sample scripts are in `bash` and in `python3`
- it can be used very easily for monitoring the system. An admin can set up a cron job that runs every 15 minutes, e.g. to check CPU temperature, or to check a log file for signs of an intrusion (e.g. SSH or Web Server log files). If anything abnormal is found by the cron job, the cron job fires off a bot message to the admin. 

## Legal

There is no support and no warranty. 

## Final Thoughts

- Enjoy and have fun with it, it is cool, and easily extensible. Adjust it to your needs!
- Pull Requests are welcome :)




---
---
---







# Nio Template

A template for creating bots with
[matrix-nio](https://github.com/poljar/matrix-nio). The documentation for
matrix-nio can be found
[here](https://matrix-nio.readthedocs.io/en/latest/nio.html).

## Projects using nio-template

* [anoadragon453/msc-chatbot](https://github.com/anoadragon453/msc-chatbot) - A matrix bot for matrix spec proposals
* [anoadragon453/matrix-episode-bot](https://github.com/anoadragon453/matrix-episode-bot) - A matrix bot to post episode links
* [TheForcer/vision-nio](https://github.com/TheForcer/vision-nio) - A general purpose matrix chatbot
* [anoadragon453/matrix-reminder-bot](https://github.com/anoadragon453/matrix-reminder-bot
) - A matrix bot to remind you about things
* [anoadragon453/drawing-challenge-bot](https://github.com/anoadragon453/drawing-challenge-bot) - A matrix bot to
post historical, weekly art challenges from reddit to a room
* [alturiak/nio-smith](https://github.com/alturiak/nio-smith) - A modular bot for @matrix-org that can be dynamically
extended by plugins


Want your project listed here? [Edit this
doc!](https://github.com/anoadragon453/nio-template/edit/master/README.md)

## Project structure

### `main.py`

Initialises the config file, the bot store, and nio's AsyncClient (which is
used to retrieve and send events to a matrix homeserver). It also registering
some callbacks on the AsyncClient to tell it to call some functions when
certain events are received (such as an invite to a room, or a new message in a
room the bot is in).

It also starts the sync loop. Matrix clients "sync" with a homeserver, by
asking constantly asking for new events. Each time they do, the client gets a
sync token (stored in the `next_batch` field of the sync response). If the
client provides this token the next time it syncs (using the `since` parameter
on the `AsyncClient.sync` method), the homeserver will only return new event
*since* those specified by the given token.

This token is saved and provided again automatically by using the
`client.sync_forever(...)` method.

### `config.py`

This file reads a config file at a given path (hardcoded as `config.yaml` in
`main.py`), processes everything in it and makes the values available to the
rest of the bot's code so it knows what to do. Most of the options in the given
config file have default values, so things will continue to work even if an
option is left out of the config file. Obviously there are some config values
that are required though, like the homeserver URL, username, access token etc.
Otherwise the bot can't function.

### `storage.py`

Creates (if necessary) and connects to a SQLite3 database and provides commands
to put or retrieve data from it. Table definitions should be specified in
`_initial_setup`, and any necessary migrations should be put in
`_run_migrations`. There's currently no defined method for how migrations
should work though.

### `callbacks.py`

Holds callback methods which get run when the bot get a certain type of event
from the homserver during sync. The type and name of the method to be called
are specified in `main.py`. Currently there are two defined methods, one that
gets called when a message is sent in a room the bot is in, and another that
runs when the bot receives an invite to the room.

The message callback function, `message`, checks if the message was for the
bot, and whether it was a command. If both of those are true, the bot will
process that command.

The invite callback function, `invite`, processes the invite event and attempts
to join the room. This way, the bot will auto-join any room it is invited to.

### `bot_commands.py`

Where all the bot's commands are defined. New commands should be defined in
`process` with an associated private method. `echo` and `help` commands are
provided by default.

A `Command` object is created when a message comes in that's recognised as a
command from a user directed at the bot (either through the specified command
prefix (defined by the bot's config file), or through a private message
directly to the bot. The `process` command is then called for the bot to act on
that command.

### `message_responses.py`

Where responses to messages that are posted in a room (but not necessarily
directed at the bot) are specified. `callbacks.py` will listen for messages in
rooms the bot is in, and upon receiving one will create a new `Message` object
(which contains the message text, amongst other things) and calls `process()`
on it, which can send a message to the room as it sees fit.

A good example of this would be a Github bot that listens for people mentioning
issue numbers in chat (e.g. "We should fix #123"), and the bot sending messages
to the room immediately afterwards with the issue name and link.

### `chat_functions.py`

A separate file to hold helper methods related to messaging. Mostly just for
organisational purposes. Currently just holds `send_text_to_room`, a helper
method for sending formatted messages to a room.

### `errors.py`

Custom error types for the bot. Currently there's only one special type that's
defined for when a error is found while the config file is being processed.

### `sample.config.yaml`

The sample configuration file. People running your bot should be advised to
copy this file to `config.yaml`, then edit it according to their needs. Be sure
never to check the edited `config.yaml` into source control since it'll likely
contain sensitive details like passwords!

## Questions?

Any questions? Ask in
[#nio-template:amorgan.xyz](https://matrix.to/#/!vmWBOsOkoOtVHMzZgN:amorgan.xyz?via=amorgan.xyz)!
