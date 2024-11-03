# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2023)
{ config, pkgs, lib, ... }:
{
	# This module doesn’t work properly on NixOS 24.05 if you use the
	# latest version of the Linux kernel. We use the latest version of the
	# Linux kernel (see ./bcachefs.nix), so we have to disable this module.
	config = lib.modules.mkIf (config.system.nixos.release != "24.05") {
		programs.cdemu = {
			enable = true;
			gui = true;
		};
		users.users.jayman.extraGroups = [
			config.programs.cdemu.group
		];
	};
}
