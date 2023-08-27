#! /usr/bin/env nix-shell
#! nix-shell -i bash -p git
# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2023)
set -e

readonly config_dir="/etc/nixos"
readonly imports_dir="$config_dir/imports"

function copy_and_restrict {
	# Usage: copy_and_restrict <mode> <file> [file]…
	local -r mode="$1"
	shift
	sudo cp -r "$@" "$config_dir"
	for src in "$@"; do
		local dest="$config_dir/$src"
		sudo chown -R root:root "$dest"
		sudo chmod -R "$mode" "$dest"
	done
}

if [ -e "$imports_dir" ]
then
	sudo rm -r "$imports_dir"
fi

copy_and_restrict u=X,g=,o= imports/
if [ "$switch" = yes ]; then
	sudo nixos-rebuild switch --no-build-nix
else
	./update.sh
fi
