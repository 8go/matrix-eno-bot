import sys
import os
import logging
import yaml
import re  # regular expression matching

logger = logging.getLogger(__name__)


class CommandDictSanityError(Exception):
    pass


class CommandDict:

    # Default formatting options
    # Mirror the defaults in the definition of the send_text_to_room
    # function in chat_functions.py which in turn mirror
    # the defaults of the Matrix API.
    DEFAULT_OPT_MARKDOWN_CONVERT = True
    DEFAULT_OPT_FORMATTED        = True
    DEFAULT_OPT_CODE             = False
    DEFAULT_OPT_SPLIT            = None

    def __init__(self, command_dict_filepath):
        """Initialize command dictionary.

        Arguments:
        ---------
            command_dict (str): Path to command dictionary.

        """

        self.command_dict = None
        self.commands = {}

        self._last_matched_command = None

        self.load(command_dict_filepath)

        self.assert_sanity()

        return

    def __contains__(self, command):
        return command in self.commands.keys()

    def __getitem__(self, item):
        return self.commands[item]

    def __iter__(self):
        return self.commands.__iter__()

    def load(self, command_dict_filepath):
        """Try loading the command dictionary.

        Arguments:
        ----------
            command_dict_filepath (string): path to command dictionary.

        """
        try:
            with open(command_dict_filepath) as fobj:
                logger.debug(f"Loading command dictionary at {command_dict_filepath}")
                self.command_dict = yaml.safe_load(fobj.read())

            if "commands" in self.command_dict.keys():
                self.commands = self.command_dict["commands"]

            if "paths" in self.command_dict.keys():
                os.environ["PATH"] = os.pathsep.join(self.command_dict["paths"]+[os.environ["PATH"]])
                logger.debug(f'Path modified. Now: {os.environ["PATH"]}.')

        except FileNotFoundError:
            logger.error(f"File not found: {command_dict_filepath}")

        return

    def is_empty(self):
        """Returns whether there are commands in the dictionary.

        """
        return len(self.commands) == 0

    def assert_sanity(self):
        """Raises a CommandDictSanityError exception if the command dictionary
        is not considered "sane".
        
        """
        # Maybe in the future: Check whether commands can be found in path
        # For now, let the OS handle this

        # Check whether command dictionary has a correct structure. Namely,
        # that:
        #
        # 1. Toplevel children may only be called "commands" or "paths".
        if len(self.command_dict) > 2:
            raise CommandDictSanityError("Only two toplevel children allowed.")
        for key in self.command_dict.keys():
            if key not in ("commands","paths"):
                raise CommandDictSanityError(
                    f"Invalid toplevel child found: {key}.")
        # 2. "paths" node must be a list, and must only contain string
        #     children.
        if "paths" in self.command_dict:
            if type(self.command_dict["paths"]) != list:
                raise CommandDictSanityError(
                    "The \"paths\" node must be a list.")
            for path in self.command_dict["paths"]:
                if type(path) != str:
                    raise CommandDictSanityError("Defined paths must be strings.")
        # 3. "commands" node chilren (henceforth command nodes) must be
        #    dictionaries, 
        # 4. and may contain only the following keys:
        #    "regex", "cmd", "help", "markdown_convert", "formatted",
        #    "code" and "split".
        # 5. The command node children may only be strings.
        # 6. Command node children with keys "markdown_convert",
        #    "formatted" or "code" may only be defined as "true" or as
        #    "false".
        if "commands" in self.command_dict.keys():
            for com in self.command_dict["commands"]:
                # Implement rule 3
                if type(self.command_dict["commands"][com]) != dict:
                    raise CommandDictSanityError(
                        "Defined commands must be dictionaries.")
                for opt in self.command_dict["commands"][com].keys():
                    # Implement rule 4
                    if opt not in ("regex",
                                   "cmd",
                                   "help",
                                   "markdown_convert",
                                   "formatted",
                                   "code",
                                   "split"):
                        raise CommandDictSanityError(
                            f"In command \"{com}\", invalid option found: " \
                            f"\"{opt}\".")
                    # Implement rule 6
                    elif opt in ("markdown_convert", "formatted", "code"):
                        if type(self.command_dict["commands"][com][opt]) != bool:
                            raise CommandDictSanityError(
                                f"In command \"{com}\", invalid value for option "
                                f"\"{opt}\" found: " \
                                f"\"{self.command_dict['commands'][com][opt]}\"")
                    # Implement rule 5
                    else:
                        if type(self.command_dict["commands"][com][opt]) != str:
                            raise CommandDictSanityError(
                                f"In command \"{com}\", command option " \
                                f"\"{opt}\" must be a string.")

        return

    def match(self, string):
        """Returns whether the given string matches any of the commands' names
        regex patterns.

        Arguments:
        ----------
            string (str): string to match

        """
        matched = False
        cmd = None

        if string in self.commands.keys():
            matched = True
            cmd = string

        else:
            for command in self.commands.keys():
                if  "regex" in self.commands[command].keys() \
                and re.match(self.commands[command]["regex"], string):
                    matched = True
                    cmd = command
                    break
            
        if cmd and len(cmd) > 0:
            self._last_matched_command = cmd
        else:
            self._last_matched_command = None

        return matched

    def get_last_matched_command(self):
        return self._last_matched_command

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
        if "help" in self.commands[command]:
            return self.commands[command]["help"]
        else:
            return "No help defined for this command."

    def get_opt_markdown_convert(self, command):
        """Return boolean of the "markdown_convert" option.

        Arguments:
        ----------
            command (str): Name of the command in the command dictionary

        """
        if "markdown_convert" in self.command_dict["commands"][command].keys():
            return self.command_dict["commands"][command]["markdown_convert"]
        else:
            return CommandDict.DEFAULT_OPT_MARKDOWN_CONVERT

    def get_opt_formatted(self, command):
        """Return boolean of the "formatted" option.

        Arguments:
        ----------
            command (str): Name of the command in the command dictionary

        """
        if "formatted" in self.command_dict["commands"][command].keys():
            return self.command_dict["commands"][command]["formatted"]
        else:
            return CommandDict.DEFAULT_OPT_FORMATTED

    def get_opt_code(self, command):
        """Return boolean of the "code" option.

        Arguments:
        ----------
            command (str): Name of the command in the command dictionary

        """
        if "code" in self.command_dict["commands"][command].keys():
            return self.command_dict["commands"][command]["code"]
        else:
            return CommandDict.DEFAULT_OPT_CODE

    def get_opt_split(self, command):
        """Return the string defined in the "split" option, or None.

        Arguments:
        ----------
            command (str): Name of the command in the command dictionary

        """
        if "split" in self.command_dict["commands"][command].keys():
            return self.command_dict["commands"][command]["split"]
        else:
            return CommandDict.DEFAULT_OPT_SPLIT

