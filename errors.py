#!/usr/bin/env python3

r"""errors.py.

0123456789012345678901234567890123456789012345678901234567890123456789012345678
0000000000111111111122222222223333333333444444444455555555556666666666777777777

# errors.py

Don't change tabbing, spacing, or formating as the
file is automatically linted and beautified.

"""


class ConfigError(RuntimeError):
    """Error encountered during reading the config file.

    Arguments:
    ---------
        msg (str): The message displayed to the user on error

    """

    def __init__(self, msg):
        """Set up."""
        super(ConfigError, self).__init__("%s" % (msg,))
