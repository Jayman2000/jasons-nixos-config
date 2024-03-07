# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
{ config, ... }:

{
	services.openssh = {
		enable = true;
		settings.PermitRootLogin = "no";
	};
	users.users.jayman.openssh.authorizedKeys.keys = [
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILWQkgb4A4mvzHeXAm6ghxfknl15cttipb56qP0IpBlj Jason-Desktop-Linux"
	];
	# This is required for the following command to work:
	#
	# nixos-rebuild boot --target-host jayman@<host> --use-remote-sudo
	#
	# See <https://github.com/NixOS/nixpkgs/issues/159082>.
	nix.settings.trusted-users = [ "jayman" ];
}
