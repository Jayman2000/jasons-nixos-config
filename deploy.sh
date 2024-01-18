#!/usr/bin/env bash
# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2024)
set -e

if ! type nix-shell &> /dev/null
then
	echo "ERROR: the nix-shell command isn’t available." 1>&2
	exit 1
fi

nix-shell deploy-shell.nix
