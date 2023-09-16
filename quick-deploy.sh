#!/usr/bin/env nix-shell
#! nix-shell -i bash -p nix
# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2023)
set -e
# See sysexits.h.
readonly ex_usage=64

if [ "$#" -eq 1 ]
then
	if [ "$1" = shutdown ] || [ "$1" = reboot ]
	then
		sudo -v
		pushd imports/applications
		nix-build nicely-stop-session.nix
		popd
		./deploy.sh
		./imports/applications/result/bin/nicely-stop-session "$1"
	else
		echo -E \
			"ERROR: Invalid session stop type  “$1”. It" \
			"should either be “shutdown” or “reboot”." 1>&2
		exit "$ex_usage"
	fi
else
	echo -E \
		"ERROR: 1 argument should have been given, but $#" \
		"were given." 1>&2
	exit "$ex_usage"
fi
