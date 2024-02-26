#!/usr/bin/env bash
# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2023–2024)
source src/pkgCollections/custom/bash-preamble/preamble.sh
# See sysexits.h.
readonly ex_usage=64

for dependency in sudo nix-shell
do
	if ! type "$dependency" &> /dev/null
	then
		echo "ERROR: the $dependency command isn’t available." 1>&2
		exit 1
	fi
done

if [ "$#" -eq 1 ]
then
	if [ "$1" = shutdown ] || [ "$1" = reboot ]
	then
		sudo -v
		./ensure-password-files-exist.sh
		readonly script="
			env \
				JNC_NIXOS_REBUILD_AS_ROOT=1 \
				deploy-jasons-nixos-config \
				boot \
				--upgrade && \
					nicely-stop-session $1
		"
		nix-shell quick-deploy-shell.nix --run "$script"
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
