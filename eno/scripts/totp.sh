#!/bin/bash

# Example URI:
# otpauth://totp/Example:alice@google.com?secret=JBSWY3DPEHPK3PXP&issuer=Example

# Example TOTP secret key:
# JBSWY3DPEHPK3PXP

# TOTP secret can be password protected thru a 2nd argument

# Do this to encypt a TOTP secret key:
# echo "JBSWY3DPEHPK3PXP" | openssl enc -aes-256-cbc -salt -a -pbkdf2 # returns encrypted TOTP key
# "U2FsdGVkX1+etVuH68uNDv1v5J+XfYXRSuuEyypLJrEGCfo4V91eICW1085lQa68" # TOTP secret key "JBSWY3DPEHPK3PXP" encrypted with passphrase "test"

# the reverse is: decrypted the cipher text to get original TOTP secret key, in the example we use passphrase "test"
# echo "U2FsdGVkX1+etVuH68uNDv1v5J+XfYXRSuuEyypLJrEGCfo4V91eICW1085lQa68"  | openssl enc -aes-256-cbc -d -salt -a -pbkdf2 -k test # returns "JBSWY3DPEHPK3PXP"
# JBSWY3DPEHPK3PXP

# oathtool must be installed
type oathtool >/dev/null 2>&1 || {
        echo "This script requires that you install the packge \"oathtool\" on the server."
        exit 0
}

function totp() {
	D="$(date +%S)"
	# shellcheck disable=SC2001
	DNOLEADINGZERO=$(echo "$D" | sed 's/^0//')
	# shellcheck disable=SC2004
	SECONDSREMAINING=$((30 - $DNOLEADINGZERO % 30))
        # [ "$DEBUG" != "" ] && echo "DEBUG: TOKEN=$1" # NEVER log this!
	X=$(oathtool --totp -b "$1")
	echo "$SECONDSREMAINING seconds remaining : $X"
}

if [ "$#" == "0" ]; then
	echo "No TOTP nick-name given. Try \"totp example-plaintext\" or \"totp example-encrypted\" next time."
	echo "This script has to be set up on the server to be meaningful."
	echo "As shipped it only has an example of a TOTP  service."
	exit 0
fi

arg1=$1
arg2=$2

case "$arg1" in
example-plaintext)
	# echo "Calculating TOTP PIN for you"
	PLAINTEXTTOTPKEY="JBSWY3DPEHPK3PXP"
	totp "$PLAINTEXTTOTPKEY"
	exit 0
	;;
example-encrypted)
	# echo "Calculating TOTP PIN for you"
	if [ "$arg2" == "" ]; then
		echo "A password is required for this TOTP nick name."
		exit 0
	fi
	CIPHERTOTPKEY="U2FsdGVkX1+etVuH68uNDv1v5J+XfYXRSuuEyypLJrEGCfo4V91eICW1085lQa68"
	PLAINTEXTTOTPKEY=$(echo "$CIPHERTOTPKEY" | openssl enc -aes-256-cbc -d -salt -a -pbkdf2 -k "$arg2")
	totp "$PLAINTEXTTOTPKEY"
	# echo "Using \"$arg2\" as password. Totp secret is \"$TOTPSECRET\"."
	exit 0
	;;
*)
	echo "Unknown TOTP nick name \"$arg1\". Not configured on server."
	;;
esac

# EOF
