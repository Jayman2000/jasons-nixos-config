# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2023)
{ config, pkgs, ... }:
{
	imports = [
		./home-manager/unstable.nix
		./common.nix
		./auto-upgrade.nix
		./efi.nix
		./git-server.nix
	];

	time.timeZone = "America/New_York";

	# The goal here is to make networking.fqdn accurate.
	networking.hostName = "jasonyundt";
}
