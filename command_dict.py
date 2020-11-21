import sys
import os
import logging
import yaml

logger = logging.getLogger(__name__)

class CommandDict:

    def __init__(self, command_dict_filepath):
        """Initialize command dictionary.

        Arguments:
        ---------
            command_dict (str): Path to command dictionary.

        """

        self.command_dict = None
        self.commands = {}

        if command_dict_filepath:
            try:
                with open(command_dict_filepath) as fobj:
                    logger.debug(f"Loading command dictionary at {command_dict_filepath}")
                    self.command_dict = yaml.safe_load(fobj.read())

                if "commands" in self.command_dict.keys():
                    self.commands = self.command_dict["commands"]

                if "paths" in self.command_dict.keys():
                    os.environ["PATH"] = os.pathsep.join(self.command_dict["paths"]+[os.environ["PATH"]])
                    logger.debug(f'Path modified. Now: {os.environ["PATH"]}')

            except FileNotFoundError:
                logger.error(f"File not found: {command_dict_filepath}")

        return

    def __contains__(self, command):
        return command in self.commands.keys()

    def __getitem__(self, item):
        return self.commands[item]

    def get_cmd(self, command):
        """Return the name of the executable associated with the given command,
        for the system to call.

        Arguments:
        ----------
            command (str): Name of the command in the command dictionary

        """
        return self.commands[command]["cmd"]

    def get_help(self,command):
        """Return the help string of the given command.

        Arguments:
        ----------
            command (str): Name of the command in the command dictionary

        """
        return self.commands[command]["help"]

