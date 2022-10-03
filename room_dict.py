import sys
import os
import logging
import yaml
import re  # regular expression matching

logger = logging.getLogger(__name__)


class RoomDictSanityError(Exception):
    pass


class RoomDict:

    # Default formatting options
    # Mirror the defaults in the definition of the send_text_to_room
    # function in chat_functions.py which in turn mirror
    # the defaults of the Matrix API.
    DEFAULT_OPT_MARKDOWN_CONVERT = True
    DEFAULT_OPT_FORMATTED        = True
    DEFAULT_OPT_CODE             = False
    DEFAULT_OPT_SPLIT            = None
    DEFAULT_OPT_ARGS             = None

    def __init__(self, room_dict_filepath):
        """Initialize room dictionary.

        Arguments:
        ---------
            room_dict (str): Path to room dictionary.

        """

        self.room_dict = None
        self.rooms = {}

        self._last_matched_room = None

        self.load(room_dict_filepath)

        self.assert_sanity()

        return

    def __contains__(self, room):
        return room in self.rooms.keys()

    def __getitem__(self, item):
        return self.rooms[item]

    def __iter__(self):
        return self.rooms.__iter__()

    def load(self, room_dict_filepath):
        """Try loading the room dictionary.

        Arguments:
        ----------
            room_dict_filepath (string): path to room dictionary.

        """
        try:
            with open(room_dict_filepath) as fobj:
                logger.debug(f"Loading room dictionary at {room_dict_filepath}")
                self.room_dict = yaml.safe_load(fobj.read())

            if "rooms" in self.room_dict.keys():
                self.rooms = self.room_dict["rooms"]

            if "paths" in self.room_dict.keys():
                os.environ["PATH"] = os.pathsep.join(self.room_dict["paths"]+[os.environ["PATH"]])
                logger.debug(f'Path modified. Now: {os.environ["PATH"]}.')

        except FileNotFoundError:
            logger.error(f"File not found: {room_dict_filepath}")

        return

    def is_empty(self):
        """Returns whether there are rooms in the dictionary.

        """
        return len(self.rooms) == 0

    def assert_sanity(self):
        """Raises a RoomDictSanityError exception if the room dictionary
        is not considered "sane".
        
        """
        # Maybe in the future: Check whether rooms can be found in path
        # For now, let the OS handle this

        # Check whether room dictionary has a correct structure. Namely,
        # that:
        #
        # 1. Toplevel children may only be called "rooms" or "paths".
        if len(self.room_dict) > 2:
            raise RoomDictSanityError("Only two toplevel children allowed.")
        for key in self.room_dict.keys():
            if key not in ("rooms","paths"):
                raise RoomDictSanityError(
                    f"Invalid toplevel child found: {key}.")
        # 2. "paths" node must be a list, and must only contain string
        #     children.
        if "paths" in self.room_dict:
            if type(self.room_dict["paths"]) != list:
                raise RoomDictSanityError(
                    "The \"paths\" node must be a list.")
            for path in self.room_dict["paths"]:
                if type(path) != str:
                    raise RoomDictSanityError("Defined paths must be strings.")
        # 3. "rooms" node chilren (henceforth room nodes) must be
        #    dictionaries, 
        # 4. and may contain only the following keys:
        #    "regex", "cmd", "help", "markdown_convert", "formatted",
        #    "code" and "split".
        # 5. The room node children may only be strings.
        # 6. Room node children with keys "markdown_convert",
        #    "formatted" or "code" may only be defined as "true" or as
        #    "false".
        if "rooms" in self.room_dict.keys():
            for com in self.room_dict["rooms"]:
                # Implement rule 3
                if type(self.room_dict["rooms"][com]) != dict:
                    raise RoomDictSanityError(
                        "Defined rooms must be dictionaries.")
                for opt in self.room_dict["rooms"][com].keys():
                    # Implement rule 4
                    if opt not in ("regex",
                                   "cmd",
                                   "args",
                                   "help",
                                   "markdown_convert",
                                   "formatted",
                                   "code",
                                   "split"):
                        raise RoomDictSanityError(
                            f"In room \"{com}\", invalid option found: " \
                            f"\"{opt}\".")
                    # Implement rule 6
                    elif opt in ("markdown_convert", "formatted", "code"):
                        if type(self.room_dict["rooms"][com][opt]) != bool:
                            raise RoomDictSanityError(
                                f"In room \"{com}\", invalid value for option "
                                f"\"{opt}\" found: " \
                                f"\"{self.room_dict['rooms'][com][opt]}\"")
                    # Implement rule 5
                    else:
                        if type(self.room_dict["rooms"][com][opt]) != str:
                            raise RoomDictSanityError(
                                f"In room \"{com}\", room option " \
                                f"\"{opt}\" must be a string.")

        return

    def match(self, string):
        """Returns whether the given string matches any of the rooms' names
        regex patterns.

        Arguments:
        ----------
            string (str): string to match

        """
        matched = False
        cmd = None

        if string in self.rooms.keys():
            matched = True
            cmd = string

        else:
            for room in self.rooms.keys():
                if  "regex" in self.rooms[room].keys() \
                and re.match(self.rooms[room]["regex"], string):
                    matched = True
                    cmd = room
                    break
            
        self._last_matched_room = cmd

        return matched

    def get_last_matched_room(self):
        return self._last_matched_room

    def get_cmd(self, room):
        """Return the name of the executable associated with the given room,
        for the system to call.

        Arguments:
        ----------
            room (str): Name of the room in the room dictionary

        """
        return self.rooms[room]["cmd"]

    def get_help(self,room):
        """Return the help string of the given room.

        Arguments:
        ----------
            room (str): Name of the room in the room dictionary

        """
        if "help" in self.rooms[room]:
            return self.rooms[room]["help"]
        else:
            return "No help defined for this room."

    def get_opt_args(self, room):
        """Return value of the "args" option.

        Arguments:
        ----------
            room (str): Name of the room in the room dictionary

        """
        if "args" in self.room_dict["rooms"][room].keys():
            return self.room_dict["rooms"][room]["args"].split()
        else:
            return RoomDict.DEFAULT_OPT_ARGS

    def get_opt_markdown_convert(self, room):
        """Return boolean of the "markdown_convert" option.

        Arguments:
        ----------
            room (str): Name of the room in the room dictionary

        """
        if "markdown_convert" in self.room_dict["rooms"][room].keys():
            return self.room_dict["rooms"][room]["markdown_convert"] == "true"
        else:
            return RoomDict.DEFAULT_OPT_MARKDOWN_CONVERT

    def get_opt_formatted(self, room):
        """Return boolean of the "formatted" option.

        Arguments:
        ----------
            room (str): Name of the room in the room dictionary

        """
        if "formatted" in self.room_dict["rooms"][room].keys():
            return self.room_dict["rooms"][room]["formatted"] == "true"
        else:
            return RoomDict.DEFAULT_OPT_FORMATTED

    def get_opt_code(self, room):
        """Return boolean of the "code" option.

        Arguments:
        ----------
            room (str): Name of the room in the room dictionary

        """
        if "code" in self.room_dict["rooms"][room].keys():
            return self.room_dict["rooms"][room]["code"] == "true"
        else:
            return RoomDict.DEFAULT_OPT_CODE

    def get_opt_split(self, room):
        """Return the string defined in the "split" option, or None.

        Arguments:
        ----------
            room (str): Name of the room in the room dictionary

        """
        if "split" in self.room_dict["rooms"][room].keys():
            return self.room_dict["rooms"][room]["split"]
        else:
            return RoomDict.DEFAULT_OPT_SPLIT

