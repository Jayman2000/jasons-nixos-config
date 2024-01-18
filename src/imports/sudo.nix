# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2023)
{ config, pkgs, ... }:
let
	customSudo = (import ./applications/sudo-access-granted.nix { inherit config  pkgs; });
in {
	environment.systemPackages = [ customSudo ];
	users.users.jayman.extraGroups = [ "wheel" ];
	# Make sure that running “sudo” runs our custom sudo instead of
	# the regular one.
	environment.shellInit = ''
		PATH="${customSudo}/bin:$PATH"
	'';
}
