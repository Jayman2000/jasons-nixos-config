#!/usr/bin/env bash
# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
source src/pkgCollections/custom/bash-preamble/preamble.sh
./ensure-passwords-then-run.sh \
	make-installation-usb-shell.nix \
	make-installation-usb \
	"$@"
