#!/usr/bin/env bash
# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2023)
set -e


for path in "$@"
do
	echo "Checking “$path”…"
	# The comments in kzonecheck.sh will probably help you
	# understand this part.
	cmd="$(declare -p path);"'knotc --config "$path" conf-check'
	nix-shell -p knot-dns --run "$cmd"
done
