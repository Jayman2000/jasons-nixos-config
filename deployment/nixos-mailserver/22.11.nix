# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2023)
let
	# Thanks to Robert Hensing
	# (<https://stackoverflow.com/users/428586/robert-hensing>) for helping
	# me figure out how to work around an infinite recursion problem:
	# <https://stackoverflow.com/a/73098226/7593853>
	alt_pkgs = import <nixpkgs> {};
	name = "nixos-mailserver";
	# Thanks to andir (<https://discourse.nixos.org/u/andir>) for showing me
	# how to use fetchFromGitLab in configuration.nix:
	# <https://discourse.nixos.org/t/fetchfromgithub-in-configuration-nix/5927/2?u=jasonyundt>
	nixos_mailserver = alt_pkgs.fetchFromGitLab {
		owner = "simple-${name}";
		repo = name;
		rev = "nixos-22.11";
		sha256 = "DbpT+v1POwFOInbrDL+vMbYV3mVbTkMxmJ5j50QnOcA=";
	};
in
import nixos_mailserver
