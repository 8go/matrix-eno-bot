#!/bin/bash

if [ "$#" == "0" ]; then
	echo "You must be updating something. Try \"update os\"."
	echo "\"bot\", \"matrix\", \"os\", and \"world\" are configured on server."
	exit 0
fi
arg1=$1
case "${arg1,,}" in
"bot" | "eno" | "mybot")
	echo "Sorry. The bot update is not implemented. If you really want to update your bot, add your update code here."
	;;
"matrix")
	echo "The bot will update the matrix software."
	# the name of the service might vary based on installation from : synapse-matrix, matrix, etc.
	# there are many different ways to install matrix and to update matrix.
	echo "Sorry. The matrix update is not implemented. Add it here if desired."
	;;
"os")
	echo "The bot will update the operating system"
	type apt >/dev/null 2>&1 && type dnf >/dev/null 2>&1 && echo "Don't know how to check for updates as your system does neither support apt nor dnf." && exit 0
	# dnf OR apt exists
	type dnf >/dev/null 2>&1 || {
		sudo apt-get update ||
			{
				echo "Error while using apt. Maybe due to missing permissions?"
				return 0
			}
		sudo apt-get --yes --with-new-pkgs upgrade ||
			{
				echo "Error while using apt. Maybe due to missing permissions?"
				return 0
			}
		sudo apt-get --yes autoremove ||
			{
				echo "Error while using apt. Maybe due to missing permissions?"
				return 0
			}
		sudo apt-get --yes autoclean ||
			{
				echo "Error while using apt. Maybe due to missing permissions?"
				return 0
			}
	}
	type apt >/dev/null 2>&1 || {
		sudo dnf -y upgrade ||
			{
				echo "Error while using dnf. Maybe due to missing permissions?"
				return 0
			}
	}
	;;
"world")
	echo "Your bot will update world order. World 2.0 ready!"
	;;
*)
	echo "This bot does not know how to upgrade ${arg1}."
	echo "Only \"bot\", \"matrix\", \"os\", and \"world\" are configured on server."
	;;
esac

# EOF
