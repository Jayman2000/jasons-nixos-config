# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2023)
{
	hardware.wooting.enable = true;
	# This is needed for the udev rules to work. See
	# <https://github.com/NixOS/nixpkgs/blob/e6ab46982debeab9831236869539a507f670a129/pkgs/os-specific/linux/wooting-udev-rules/default.nix#L18>.
	users.users.jayman.extraGroups = [ "input" ];
}
