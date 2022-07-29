# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
{ config, pkgs, ... }:
{
	imports = [ ./efi.nix ];

	# TODO: Update this interface’s name.
	#networking.interfaces.enp8s0.useDHCP = true;
	time.timeZone = "America/New_York";
}
