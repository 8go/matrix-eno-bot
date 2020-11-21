#!/usr/bin/env python3

r"""bot_commands.py.

0123456789012345678901234567890123456789012345678901234567890123456789012345678
0000000000111111111122222222223333333333444444444455555555556666666666777777777

# bot_commands.py

See the implemented sample bot commands of `echo`, `date`, `dir`, `help`,
and `whoami`? Have a close look at them and style your commands after these
example commands.

Don't change tabbing, spacing, or formating as the
file is automatically linted and beautified.

"""

import getpass
import logging
import os
import re  # regular expression matching
import subprocess
from sys import platform
import traceback
from chat_functions import send_text_to_room

logger = logging.getLogger(__name__)

SERVER_ERROR_MSG = "Bot encountered an error. Here is the stack trace: \n"


class Command(object):
    """Use this class for your bot commands."""

    def __init__(self, client, store, config, command_dict, command, room, event):
        """Set up bot commands.

        Arguments:
        ---------
            client (nio.AsyncClient): The client to communicate with Matrix
            store (Storage): Bot storage
            config (Config): Bot configuration parameters
            command_dict (CommandDict): Command dictionary
            command (str): The command and arguments
            room (nio.rooms.MatrixRoom): The room the command was sent in
            event (nio.events.room_events.RoomMessageText): The event
                describing the command

        """
        self.client = client
        self.store = store
        self.config = config
        self.command_dict = command_dict
        self.command = command
        self.room = room
        self.event = event
        # self.args: list : list of arguments
        self.args = re.findall(r'(?:[^\s,"]|"(?:\\.|[^"])*")+', self.command)[
            1:
        ]
        # will work for double quotes "
        # will work for 'a bb ccc "e e"' --> ['a', 'bb', 'ccc', '"e e"']
        # will not work for single quotes '
        # will not work for "a bb ccc 'e e'" --> ['a', 'bb', 'ccc', "'e", "e'"]
        self.commandlower = self.command.lower()

    async def process(self):  # noqa
        """Process the command."""

        logger.debug(
            f"bot_commands :: Command.process: {self.command} {self.room}"
        )
        # echo
        if re.match("^echo$|^echo .*", self.commandlower):
            await self._echo()
        # help
        elif re.match(
            "^help$|^ayuda$|^man$|^manual$|^hilfe$|"
            "^je suis perdu$|^perdu$|^socorro$|^h$|"
            "^rescate$|^rescate .*|^help .*|^help.sh$",
            self.commandlower,
        ):
            await self._show_help()
        # list directory
        elif re.match("^list$|^ls$|^dir$|^directory$", self.commandlower):
            # Just an example how to call OS commands,
            # or how to call shell scripts, .bat files, etc.
            # Prepare the command with arguments and pass it into
            # await self._os_cmd().
            # You don't need to distinguish platforms. You need to prepare
            # the command only for 1 platform, your platform, for the platform
            # where you will run the bot.
            list_args = []
            if (
                platform == "linux"
                or platform == "linux2"
                or platform == "cygwin"
            ):
                # linux, linux-like
                list_cmd = "ls"
                list_args = ["-al"]
            elif platform == "darwin":
                # OS X, Mac
                list_cmd = "ls"
            elif platform == "win32" or platform == "windows":
                # Windows...
                list_cmd = "dir"
            else:
                # Java, OpenVMS, etc.
                logger.debug(
                    "Operating system or platform not supported "
                    'for the "list" command. Sorry.'
                )
                return
            await self._os_cmd(
                cmd=list_cmd,
                args=list_args,
                markdown_convert=False,
                formatted=True,
                code=True,
            )
        # show date (and time on linux)
        elif re.match(
            "^date$|^datum$|^data$|^fecha$|" "^time$|^hora$|^heure$|^uhrzeit$",
            self.commandlower,
        ):
            # Just an example how to call OS commands,
            # or how to call shell scripts, .bat files, etc.
            # Prepare the command with arguments and pass it into
            # await self._os_cmd().
            # You don't need to distinguish platforms. You need to prepare
            # the command only for 1 platform, your platform, for the platform
            # where you will run the bot.
            date_args = []
            if (
                platform == "linux"
                or platform == "linux2"
                or platform == "cygwin"
            ):
                # linux, linux-like
                date_cmd = "date"
                date_args = ["--utc"]
            elif platform == "darwin":
                # OS X, Mac
                date_cmd = "date"
            elif platform == "win32" or platform == "windows":
                # Windows...
                date_cmd = "DATE"
                date_args = ["/T"]
            else:
                # Java, OpenVMS, etc.
                logger.debug(
                    "Operating system or platform not supported "
                    'for the "list" command. Sorry.'
                )
                return
            await self._os_cmd(
                cmd=date_cmd,
                args=date_args,
                markdown_convert=False,
                formatted=True,
                code=True,
            )
        # whoami
        elif re.match("^w$|^who$|^whoami$", self.commandlower):
            await self._whoami()
        # # add your own commands here
        # # short description of your command
        # elif re.match("^your-regular-expression", self.commandlower):
        #    await self._your_command_function()
        # # and repeat this for every command in your bot

        # from here on put the commands in alphabetical order
        # alert if too many resources are used, best to use with cron
        elif re.match(
            "alert$|^alert .*$|^alarm$|^alarm .*|^alert.sh$", self.commandlower
        ):
            await self._os_cmd(
                cmd="alert.sh",
                args=self.args,
                markdown_convert=False,
                formatted=True,
                code=True,
            )
        # perform a backup to disk
        elif re.match("^backup$|^backup .*$|^backup.sh$", self.commandlower):
            await self._os_cmd(
                cmd="backup.sh",
                args=self.args,
                markdown_convert=False,
                formatted=True,
                code=True,
            )
        # get BTC ticker
        elif re.match("^btc$|^btc .*$|^bitcoin$|^btc.sh$", self.commandlower):
            await self._os_cmd(
                cmd="btc.sh",
                args=self.args,
                markdown_convert=False,
                formatted=True,
                code=True,
            )
        # get cheatsheets, see https://github.com/cheat/cheat
        elif re.match(
            "^cheat$|^cheatsheet$|^chuleta$|^cheat.sh$|"
            "^cheat .*$|^cheatsheet .*$|^chuleta .*$|^cheat.sh .*$",
            self.commandlower,
        ):
            await self._os_cmd(
                cmd="cheat",
                args=self.args,
                markdown_convert=False,
                formatted=True,
                code=True,
            )
        # check status and look for updates
        elif re.match(
            "^check$|^chk$|^status$|^state$|^check .*$|"
            "^chk .*|^status .*$|^state .*$|^check.sh$|"
            "^check.sh .*",
            self.commandlower,
        ):
            await self._os_cmd(
                cmd="check.sh",
                args=self.args,
                markdown_convert=False,
                formatted=True,
                code=False,
            )
        # CPU temperature
        elif re.match(
            "^cpu$|^temp$|^temperature$|^celsius$|^cputemp.*$|"
            "^hot$|^chaud$",
            self.commandlower,
        ):
            await self._os_cmd(
                cmd="cputemp.sh",
                args=self.args,
                markdown_convert=False,
                formatted=True,
                code=False,
            )
        # get date and time
        elif re.match(
            "^date$|^time$|^tiempo$|^hora$|^temps$|^heure$|"
            "^heures$|^datum$|^zeit$|^datetime.sh$",
            self.commandlower,
        ):
            await self._os_cmd(
                cmd="datetime.sh",
                args=self.args,
                markdown_convert=False,
                formatted=True,
                code=True,
            )
        # duckduckgo
        elif re.match(
            "^ddg$|^ddg .*$|^duck$|^duck .*$|^duckduckgo$|"
            "^duckduckgo .*$|^search$|^search .*|^ddg.sh$|"
            "^ddg.sh .*",
            self.commandlower,
        ):
            await self._os_cmd(
                cmd="ddg.sh",
                args=self.args,
                markdown_convert=False,
                formatted=True,
                code=False,
            )
        # disk space
        elif re.match(
            "^disks$|^disk$|^full$|^space$|^disks.sh$", self.commandlower
        ):
            await self._os_cmd(
                cmd="disks.sh",
                args=self.args,
                markdown_convert=False,
                formatted=True,
                code=True,
            )
        # get ETH ticker
        elif re.match("^eth$|^eth .*$|^ethereum$|^eth.sh$", self.commandlower):
            await self._os_cmd(
                cmd="eth.sh",
                args=self.args,
                markdown_convert=False,
                formatted=True,
                code=True,
            )
        # get firewall settings
        elif re.match(
            "^firewall$|^fw$|^firewall .*$|^firewall.sh$", self.commandlower
        ):
            await self._os_cmd(
                cmd="firewall.sh",
                args=self.args,
                markdown_convert=False,
                formatted=True,
                code=True,
            )
        # get a compliment, hello
        elif re.match(
            "^salut$|^ciao$|^hallo$|^hi$|^servus$|^hola$|"
            "^hello$|^hello .*$|^bonjour$|^bonne nuit$|"
            "^hello.sh$",
            self.commandlower,
        ):
            await self._os_cmd(
                cmd="hello.sh",
                args=self.args,
                markdown_convert=False,
                formatted=True,
                code=False,
            )
        # hacker news
        elif re.match("^hn$|^hn .*$|^hn.sh$|^hn.sh .*", self.commandlower):
            await self._os_cmd(
                cmd="hn.sh",
                args=self.args,
                markdown_convert=False,
                formatted=True,
                code=False,
            )
        # messari news
        elif re.match("^mn$|^mn .*$|^mn.sh$|^mn.sh .*", self.commandlower):
            await self._os_cmd(
                cmd="mn.sh",
                args=self.args,
                markdown_convert=False,
                formatted=True,
                code=False,
                split="\n\n\n",
            )
        # message of the day
        elif re.match("^motd|^motd .*|^motd.sh$", self.commandlower):
            await self._os_cmd(
                cmd="motd.sh",
                args=self.args,
                markdown_convert=False,
                formatted=True,
                code=False,
            )
        # platform info
        elif re.match(
            "^platform$|^platform .*|^platforminfo.py$", self.commandlower
        ):
            await self._os_cmd(
                cmd="platforminfo.py",
                args=self.args,
                markdown_convert=False,
                formatted=True,
                code=False,
            )
        # ps, host status
        elif re.match("^ps$|^ps .*|^ps.sh$", self.commandlower):
            await self._os_cmd(
                cmd="ps.sh",
                args=self.args,
                markdown_convert=False,
                formatted=True,
                code=True,
            )
        # restart, reset
        elif re.match(
            "^restart$|^reset$|^restart .*$|^reset .*$|"
            "^restart.sh$|^restart.sh .*",
            self.commandlower,
        ):
            await self._os_cmd(
                cmd="restart.sh",
                args=self.args,
                markdown_convert=False,
                formatted=True,
                code=False,
            )
        # RSS
        elif re.match(
            "^rss$|^feed$|^rss .*$|^feed .*$|^rss.sh$|^rss.sh .*",
            self.commandlower,
        ):
            await self._os_cmd(
                cmd="rss.sh",
                args=self.args,
                markdown_convert=False,
                formatted=True,
                code=False,
                split="\n\n\n",
            )
        # Stock-to-flow
        elif re.match(
            "^s2f$|^mys2f.py.*|^flow$|^s2f|^flow .*$|^s2f .$|"
            "^s-to-f$|^stock-to-flow .*$|^eyf$|^eyf .*$|^e-y-f$",
            self.commandlower,
        ):
            await self._os_cmd(
                cmd="s2f.py",
                args=self.args,
                markdown_convert=False,
                formatted=True,
                code=True,
            )
        # tides
        elif re.match(
            "^tide$|^tides$|^marea|^mareas|^tide .*$|"
            "^tides .*$|^marea .*$|^mareas .*$|"
            "^gehzeiten .*$|^tides.sh$|^tides.sh .*",
            self.commandlower,
        ):
            await self._os_cmd(
                cmd="tides.sh",
                args=self.args,
                markdown_convert=False,
                formatted=True,
                code=False,
            )
        # top CPU, MEM consumers
        elif re.match("^top$|^top .*|^top.sh$|^top.sh .*", self.commandlower):
            await self._os_cmd(
                cmd="top.sh",
                args=self.args,
                markdown_convert=False,
                formatted=True,
                code=True,
            )
        # get TOTP 2FA pin
        elif re.match(
            "^otp$|^totp$|^otp .*$|^totp .*$|" "^totp.sh$|^totp.sh .*",
            self.commandlower,
        ):
            await self._os_cmd(
                cmd="totp.sh",
                args=self.args,
                markdown_convert=False,
                formatted=True,
                code=False,
            )
        # twitter
        elif re.match(
            "^tweet$|^twitter$|^tweet .*$|^twitter .*$|"
            "^twitter.sh$|^twitter.sh .*",
            self.commandlower,
        ):
            await self._os_cmd(
                cmd="twitter.sh",
                args=self.args,
                markdown_convert=False,
                formatted=True,
                code=False,
            )
        # update components
        elif re.match(
            "^update$|^upgrade$|^update .*$|^upgrade .*$|"
            "^update.sh$|^update.sh .*",
            self.commandlower,
        ):
            await self._os_cmd(
                cmd="update.sh",
                args=self.args,
                markdown_convert=False,
                formatted=True,
                code=False,
            )
        # list matrix users by issuing a REST API query
        elif re.match(
            "^usr$|^user$|^users$|^users .*$|^users.sh$|" "^users.sh .*",
            self.commandlower,
        ):
            await self._os_cmd(
                cmd="users.sh",
                args=self.args,
                markdown_convert=False,
                formatted=True,
                code=True,
            )
        # wake up PC via wake-on-LAN
        elif re.match(
            "^wake$|^wakeup$|^wake .*$|^wakeup .*$|"
            "^wakelan .*$|^wake.sh$|^wake .*",
            self.commandlower,
        ):
            await self._os_cmd(
                cmd="wake.sh",
                args=self.args,
                markdown_convert=False,
                formatted=True,
                code=False,
            )
        # waves and surf conditions
        elif re.match(
            "^wave$|^waves$|^wave .*$|^waves .*$|"
            "^surf$|^surf .*$|^waves.sh$",
            self.commandlower,
        ):
            await self._os_cmd(
                cmd="waves.sh",
                args=self.args,
                markdown_convert=False,
                formatted=True,
                code=True,
            )
        # get weather forecast
        elif re.match(
            "^weather$|^tiempo$|^wetter$|^temps$|"
            "^weather .*$|^tiempo .*$|^eltiempo .*$|"
            "^wetter .*$|^temps .*$|^weather.sh$|^weather.sh .*",
            self.commandlower,
        ):
            await self._os_cmd(
                cmd="weather.sh",
                args=self.args,
                markdown_convert=False,
                formatted=True,
                code=True,
            )
        # fetch web pages
        elif re.match(
            "^www$|^web$|^web .*$|^www .*$|^browse$|"
            "^browse .*|^web.sh$|^web.sh .*",
            self.commandlower,
        ):
            await self._os_cmd(
                cmd="web.sh",
                args=self.args,
                markdown_convert=False,
                formatted=True,
                code=False,
            )
        # command from command dict
        elif self.commandlower in self.command_dict:
            await self._os_cmd(
                cmd=self.command_dict.get_cmd(self.commandlower),
                args=self.args,
                markdown_convert=False,
                formatted=True,
                code=True,
            )
        else:
            await self._unknown_command()

    async def _echo(self):
        """Echo back the command's arguments."""
        response = " ".join(self.args)
        if response.strip() == "":
            response = "echo!"
        await send_text_to_room(self.client, self.room.room_id, response)

    async def _whoami(self):
        """whoami."""
        response = (
            f"- user name: `{getpass.getuser()}`\n"
            f"- home: `{os.environ['HOME']}`\n"
            f"- path: `{os.environ['PATH']}`"
        )
        await send_text_to_room(
            self.client,
            self.room.room_id,
            response,
            markdown_convert=True,
            formatted=True,
        )

    async def _show_help(self):
        """Show the help text."""
        if not self.args:
            response = (
                "Hello, I am your bot! "
                "Use `help all` or `help commands` to view "
                "available commands."
            )
            await send_text_to_room(self.client, self.room.room_id, response)
            return

        topic = self.args[0]
        if topic == "rules":
            response = "These are the rules: Act responsibly."
        elif topic == "commands" or topic == "all":
            await self._os_cmd(
                cmd="help.sh",
                args=self.args,
                markdown_convert=True,
                formatted=True,
                code=False,
            )
            return
        else:
            response = f"Unknown help topic `{topic}`!"
        await send_text_to_room(self.client, self.room.room_id, response)

    async def _unknown_command(self):
        await send_text_to_room(
            self.client,
            self.room.room_id,
            (
                f"Unknown command `{self.command}`. "
                "Try the `help` command for more information."
            ),
        )

    async def _os_cmd(
        self,
        cmd: str,
        args: list,
        markdown_convert=True,
        formatted=True,
        code=False,
        split=None,
    ):
        """Pass generic command on to the operating system.

        cmd (str): string of the command including any path,
            make sure command is found
            by operating system in its PATH for executables
            e.g. "date" for OS date command.
            cmd does not include any arguments.
            Valid example of cmd: "date"
            Invalid example for cmd: "echo 'Date'; date --utc"
            Invalid example for cmd: "echo 'Date' && date --utc"
            Invalid example for cmd: "TZ='America/Los_Angeles' date"
            If you have commands that consist of more than 1 command,
            put them into a shell or .bat script and call that script
            with any necessary arguments.
        args (list): list of arguments
            Valid example: [ '--verbose', '--abc', '-d="hello world"']
        markdown_convert (bool): value for how to format response
        formatted (bool): value for how to format response
        code (bool): value for how to format response
        """
        try:
            # create a combined argv list, e.g. ['date', '--utc']
            argv_list = [cmd] + args
            logger.debug(
                f'OS command "{argv_list[0]}" with ' f'args: "{argv_list[1:]}"'
            )
            run = subprocess.Popen(
                argv_list,  # list of argv
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                universal_newlines=True,
            )
            output, std_err = run.communicate()
            output = output.strip()
            std_err = std_err.strip()
            if run.returncode != 0:
                logger.debug(
                    f"Bot command {cmd} exited with return "
                    f"code {run.returncode} and "
                    f'stderr as "{std_err}" and '
                    f'stdout as "{output}"'
                )
                output = (
                    f"*** Error: command {cmd} returned error "
                    f"code {run.returncode}. ***\n{std_err}\n{output}"
                )
            response = output
        except Exception:
            response = SERVER_ERROR_MSG + traceback.format_exc()
            code = True  # format stack traces as code
        logger.debug(f"Sending this reply back: {response}")
        await send_text_to_room(
            self.client,
            self.room.room_id,
            response,
            markdown_convert=markdown_convert,
            formatted=formatted,
            code=code,
            split=split,
        )


# EOF
