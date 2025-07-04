# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2024)
{ config, pkgs, ... }:
{
	imports = [
		./home-manager/25.05.nix
		./common.nix
		./auto-upgrade.nix
		./efi.nix
		./git-server.nix
		./garbage-collection.nix
		./sshd.nix
	];

	time.timeZone = "America/New_York";

	# The goal here is to make networking.fqdn accurate.
	networking.hostName = "jasonyundt";
}
