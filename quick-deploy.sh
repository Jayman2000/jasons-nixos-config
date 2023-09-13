#!/usr/bin/env bash
# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2023)

# Thanks mklement0 (<https://stackoverflow.com/users/45375/mklement0>)
# for this answer: <https://stackoverflow.com/a/28776166/7593853>
if (return 0 2>/dev/null)
then
	if type nix-build > /dev/null
	then
		if [ "$#" -eq 1 ]
		then
			if [ "$1" = shutdown ] || [ "$1" = reboot ]
			then
				pushd imports/applications &&
					nix-build nicely-stop-session.nix &&
					popd &&
					./deploy.sh &&
					./imports/applications/result/bin/nicely-stop-session "$1"
			else
				echo -E \
					"ERROR: Invalid session stop" \
					"type  “$1”. It should either" \
					"be “shutdown” or" \
					"“reboot”." 1>&2
			fi
		else
			echo -E \
				"ERROR: 1 argument should have been" \
				"given, but $# were given." 1>&2
		fi
	else
		echo \
			ERROR: nix-build doesn’t appear to be on your \
			PATH. 1>&2
	fi
else
	echo -E \
		"ERROR: You can’t run this script as an executable." \
		"You have to run “source $0 (shutdown|reboot)”" 1>&2
	# See sysexits.h
	exit 64
fi
