#!/usr/bin/env bash
# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
#
# ./ensure-password-files-exist.sh needs to be run before this derivation is
# built:
#
# (import src/pkgCollections).custom.jasons-nixos-config
#
# This script exits in order to make sure that that happens. If
# ./ensure-password-files-exist.sh doesn’t get run before that derivation is
# built, then files will be missing from that derivation.
set -e
# See sysexits.h.
readonly ex_usage=64

if [ "$#" -lt 2 ]
then
	echo ERROR: This "$0" must be run with at least two arguments 1>&2
	exit "$ex_usage"
fi

./ensure-password-files-exist.sh
readonly nix_shell_file="$1"
shift
readonly cmd=( "$@" )
nix-shell --run "$(declare -p cmd); "'${cmd[@]}' "$nix_shell_file"
