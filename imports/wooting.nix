# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2023)
{
	nixpkgs.overlays = let
		unstablePkgs = import ./nixpkgs-unstable.nix;

		# This overlay is only really needed since the Wooting
		# Two HE is so new.
		overlay = (old: new: {
			# We need an updated version of this package in
			# order for there to be udev rules for the
			# Wooting Two HE.
			wooting-udev-rules = unstablePkgs.wooting-udev-rules;
			# We need an updated version of this package
			# because the version that’s currently in
			# Nixpkgs is too old to support the Wooting Two
			# HE.
			wootility = unstablePkgs.wootility;
		});
	in [ overlay ];

	hardware.wooting.enable = true;
	# This is needed for the udev rules to work. See
	# <https://github.com/NixOS/nixpkgs/blob/e6ab46982debeab9831236869539a507f670a129/pkgs/os-specific/linux/wooting-udev-rules/default.nix#L18>.
	users.users.jayman.extraGroups = [ "input" ];
}
