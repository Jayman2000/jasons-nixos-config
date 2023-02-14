#!/usr/bin/env bash
# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)

function copy_and_restrict {
	# Usage: copy_and_restrict <mode> <file> [file]…
	mode="$1"
	shift
	sudo cp -r "$@" /etc/nixos/
	for src in "$@"; do
		dest="/etc/nixos/$src"
		sudo chown -R root:root "$dest"
		sudo chmod -R "$mode" "$dest"
	done
}

copy_and_restrict u=X,g=,o= imports/
if [ "$switch" = yes ]; then
	sudo nixos-rebuild switch
else
	./update.sh
fi
