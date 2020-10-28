#!/usr/bin/env python3
"""Print distribution information to stdout."""
import platform
import sys


def linux_distribution():
    """Get distribution information."""
    try:
        return platform.linux_distribution()
    except BaseException:
        return "N/A"


print(
    """Python version: %s
linux_distribution: %s
system: %s
machine: %s
platform: %s
uname: %s
version: %s
"""
    % (
        sys.version.split("\n"),
        linux_distribution(),
        platform.system(),
        platform.machine(),
        platform.platform(),
        platform.uname(),
        platform.version(),
    )
)

# EOF
