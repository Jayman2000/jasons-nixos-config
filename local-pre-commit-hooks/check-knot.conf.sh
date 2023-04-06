#!/usr/bin/env bash
# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2023)
set -e
function clean_up
{
	rm -rf "$tempfolder"
}
trap clean_up EXIT

# Normallay, I would just do “readonly tempfolder="$(…)"”, but with set -e
# enabled, doing so won’t cause the program to crash if the part in the
# parentheses fails.
tempfolder="$(mktemp -d)"
readonly tempfolder

for path in "$@"
do
	echo "Checking “$path”…"

	conf_folder="$(dirname "$path")"
	mkdir -p "$tempfolder/$conf_folder"
	cp "$path" "$tempfolder/$path"
	pushd "$conf_folder"

	# Remove any include directives [1] that use an absolute path.
	# The absolute path probably won’t exist on the system that
	# you’re running pre-commit on.
	#
	# [1]: <https://www.knot-dns.cz/docs/3.2/html/reference.html#including-configuration>
	sed -i 's/include:\s*\/.*/' "$path"

	# The comments in kzonecheck.sh will probably help you
	# understand this part.
	cmd="$(declare -p path);"'knotc --config "$path" conf-check'
	nix-shell -p knot-dns --run "$cmd"

	popd
done
