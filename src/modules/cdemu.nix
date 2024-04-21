# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2023)
{ config, pkgs, lib, ... }:
{
	# CDEmu depends on a kernel module [1]. Unfortunately, the version of
	# that module that’s currently in Nixpkgs’s nixos-23.11 branch isn’t
	# compatible with the latest version of Linux [2]. Luckily, there’s a PR
	# that fixes this issue [3], so we can use the version of the kernel
	# module that’s in that PR.
	#
	# [1]: <https://cdemu.sourceforge.io/about/vhba/>
	# [2]: <https://github.com/NixOS/nixpkgs/issues/295717>
	# [3]: <https://github.com/NixOS/nixpkgs/pull/305046>
	nixpkgs.overlays = let
		pkgCollections = import ../pkgCollections { inherit pkgs lib; };
		pr305046Pkgs = pkgCollections.nixpkgs.pr305046;
		linuxPackagesExtension = self: super: {
			vhba = pr305046Pkgs.linuxPackages_latest.vhba;
		};
		nixpkgsOverlay = self: super: {
			linuxPackages_latest = super.linuxPackages_latest.extend linuxPackagesExtension;
		};
	in [ nixpkgsOverlay ];
	programs.cdemu = {
		enable = true;
		gui = true;
	};
	users.users.jayman.extraGroups = [
		config.programs.cdemu.group
	];
}
