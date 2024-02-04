# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
{
	pkgs ? import <nixpkgs> { },
	lib ? pkgs.lib,
	customLib ? import ../lib.nix { inherit lib; }
}:
let
	nixpkgsUnstableTarball = customLib.fetchFromGitHubNoHash {
		owner = "NixOS";
		repo = "nixpkgs";
		rev = "nixos-unstable";
	};
in
import nixpkgsUnstableTarball {}
