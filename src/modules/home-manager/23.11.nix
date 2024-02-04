# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2024)
# This essentially does nix-channel --add "<url>" home-manager
# Sources:
# <https://nix-community.github.io/home-manager/index.html#sec-install-nixos-module>
# <https://nixos.wiki/wiki/Home_Manager>
{ lib, ... }:
{
	imports = let
		customLib = import ../../lib.nix { inherit lib; };
		home-manager = customLib.fetchFromGitHubNoHash {
			owner = "nix-community";
			repo = "home-manager";
			rev = "release-23.11";
		};
	in [ "${home-manager}/nixos" ];
}
