#!/usr/bin/env python3

import platform
import sys
import os

def linux_distribution():
    try:
        return platform.linux_distribution()
    except BaseException:
        return "N/A"


print("""Python version: %s
linux_distribution: %s
system: %s
machine: %s
platform: %s
uname: %s
version: %s
""" % (
    sys.version.split('\n'),
    linux_distribution(),
    platform.system(),
    platform.machine(),
    platform.platform(),
    platform.uname(),
    platform.version(),
))

# EOF
