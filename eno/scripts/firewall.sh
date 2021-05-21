#!/bin/bash

# ufw must be installed
type ufw >/dev/null 2>&1 || {
	echo "This script requires that you install the packge \"ufw\" on the server to check your firewall."
	exit 0
}

fi=$(sudo ufw status verbose)
bold=$(tput bold)
red=$(tput setaf 1)
yellow=$(tput setaf 3)
green=$(tput setaf 2)
reset=$(tput sgr0)
fi=${fi//deny/${green}${bold}deny${reset}}
fi=${fi//reject/${yellow}${bold}reject${reset}}
fi=${fi//allow/${red}${bold}allow${reset}}
fi=${fi//disabled/${green}${bold}disabled${reset}}
fi=${fi//enabled/${red}${bold}enabled${reset}}
echo -e -n "$fi"
echo

# EOF
