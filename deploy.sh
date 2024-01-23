#!/usr/bin/env nix-shell
#! nix-shell -i bash deploy-shell.nix
# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2024)
set -e

JNC_NIXOS_REBUILD_AS_ROOT=1 deploy-jasons-nixos-config boot --upgrade
