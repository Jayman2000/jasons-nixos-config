# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
{ lib, ... }:
{
	imports = let
		tarball = import ../../misc/disko-tarball.nix { inherit lib; };
	in [ "${tarball}/module.nix" ];
}
