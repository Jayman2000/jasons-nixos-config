# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
{ config, pkgs, ... }:
{
	environment.systemPackages = [ (import ./applications/swapspace.nix) ];
	boot.tmpOnTmpfs = true;
	# This is probably way more than I need, but I have a lot of swap, so
	# it’s probably fine.
	boot.tmpOnTmpfsSize = "290%";
}
