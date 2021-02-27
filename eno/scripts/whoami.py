#!/usr/bin/env python3

"""whoami."""

import os
from getpass import getuser

if __name__ == "__main__":
    print(f"- user name: `{getuser()}`\n"
          f"- home: `{os.environ['HOME']}`\n"
          f"- path: `{os.environ['PATH']}`")
