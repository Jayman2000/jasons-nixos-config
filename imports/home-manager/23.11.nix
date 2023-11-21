# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2023)
# This essentially does nix-channel --add "<url>" home-manager
# Sources:
# <https://nix-community.github.io/home-manager/index.html#sec-install-nixos-module>
# <https://nixos.wiki/wiki/Home_Manager>
#
# TODO: At the moment, there’s no release-23.11 branch for Home Manager,
# so were using the master branch. This should be changed once there’s a
# 23.11 branch for Home Manager.
let
	home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in
import "${home-manager}/nixos"
