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
import time
from chat_functions import send_text_to_room

logger = logging.getLogger(__name__)

SERVER_ERROR_MSG = "Bot encountered an error. Here is the stack trace: \n"


class Command(object):
    """Use this class for your bot commands."""

    def __init__(self, client, store, config, command_dict, command, room_dict, room, event):
        """Set up bot commands.

        Arguments:
        ---------
            client (nio.AsyncClient): The client to communicate with Matrix
            store (Storage): Bot storage
            config (Config): Bot configuration parameters
            command_dict (CommandDict): Command dictionary
            command (str): The command and arguments
            room_dict (RoomDict): Room dictionary
            room (nio.rooms.MatrixRoom): The room the command was sent in
            event (nio.events.room_events.RoomMessageText): The event
                describing the command

        """
        self.client = client
        self.store = store
        self.config = config
        self.command_dict = command_dict
        self.command = command
        self.room_dict = room_dict
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

        if re.match(
            "^help$|^ayuda$|^man$|^manual$|^hilfe$|"
            "^je suis perdu$|^perdu$|^socorro$|^h$|"
            "^rescate$|^rescate .*|^help .*|^help.sh$",
            self.commandlower,
        ):
            await self._show_help()

        # command from room dict
        elif self.room_dict.match(self.room.display_name):
            matched_cmd = self.room_dict.get_last_matched_room()
            await self._os_cmd(
                cmd=self.room_dict.get_cmd(matched_cmd),
                args=self.room_dict.get_opt_args(matched_cmd),
                markdown_convert=self.room_dict.get_opt_markdown_convert(matched_cmd),
                formatted=self.room_dict.get_opt_formatted(matched_cmd),
                code=self.room_dict.get_opt_code(matched_cmd),
                split=self.room_dict.get_opt_split(matched_cmd),
            )

        # command from command dict
        elif self.command_dict.match(self.commandlower):
            matched_cmd = self.command_dict.get_last_matched_command()
            await self._os_cmd(
                cmd=self.command_dict.get_cmd(matched_cmd),
                args=self.args,
                markdown_convert=self.command_dict.get_opt_markdown_convert(matched_cmd),
                formatted=self.command_dict.get_opt_formatted(matched_cmd),
                code=self.command_dict.get_opt_code(matched_cmd),
                split=self.command_dict.get_opt_split(matched_cmd),
            )

        else:
            await self._unknown_command()

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
            if not self.command_dict.is_empty():
                response = "Available commands:\n"
                for icom in self.command_dict:
                    response += f"\n- {icom}: {self.command_dict.get_help(icom)}"
                await send_text_to_room(
                    self.client,
                    self.room.room_id,
                    response,
                    markdown_convert=True,
                    formatted=True,
                    code=False,
                    split=None,
                )

            else:
                response = "Your command dictionary seems to be empty!"

            return
        else:
            response = f"Unknown help topic `{topic}`!"
        await send_text_to_room(self.client, self.room.room_id, response)

    async def _unknown_command(self):
        await send_text_to_room(
            self.client,
            self.room.room_id,
            (
                f"{self.command}\n"
                "Try the *help* command for more information."
            ),
            split="\n",
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
            argv_list = [cmd]
            if args is not None:
                argv_list += args

            logger.debug(
                f'OS command "{argv_list[0]}" with ' f'args: "{argv_list[1:]}"'
            )

            # Set environment variables for the subprocess here.
            # Env variables like PATH, etc. are already set. In order to not lose
            # any set env variables we must merge existing env variables with the
            # new env variable(s). subprocess.Popen must be called with the
            # complete combined list.
            new_env = os.environ.copy()
            new_env['ENO_SENDER'] = self.event.sender
            new_env['ENO_TIMESTAMP_SENT'] = str(int(self.event.server_timestamp / 1000))
            new_env['ENO_TIMESTAMP_RECEIVED'] = time.strftime("%s")

            run = subprocess.Popen(
                argv_list,  # list of argv
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                universal_newlines=True,
                env=new_env,
            )
            run.stdin.write( self.command )
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
