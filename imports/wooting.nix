# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2023)
{
	nixpkgs.overlays = let
		# <https://github.com/NixOS/nixpkgs/pull/225055>
		updatedUdevPkgs = let
			url = "https://github.com/jtrees/nixpkgs/archive/refs/heads/update-wooting-udev-rules.tar.gz";
			tarball = builtins.fetchTarball url;
		in import tarball {};
		# <https://github.com/NixOS/nixpkgs/pull/225053>
		updatedWootilityPkgs = let
			url = "https://github.com/jtrees/nixpkgs/archive/refs/heads/update-wootility.tar.gz";
			tarball =  builtins.fetchTarball url;
		in import tarball {};

		# This overlay is only really needed since the Wooting
		# Two HE is so new.
		overlay = (old: new: {
			# We need an updated version of this package in
			# order for there to be udev rules for the
			# Wooting Two HE.
			wooting-udev-rules = updatedUdevPkgs.wooting-udev-rules;
			# We need an updated version of this package
			# because the version that’s currently in
			# Nixpkgs is too old to support the Wooting Two
			# HE.
			wootility = updatedWootilityPkgs.wootility;
		});
	in [ overlay ];

	hardware.wooting.enable = true;
	# This is needed for the udev rules to work. See
	# <https://github.com/jtrees/nixpkgs/blob/7918cf7ed4f1c6f8dfc009460a253fe0c6169bf0/nixos/modules/hardware/wooting.nix#L11>.
	users.users.jayman.extraGroups = [ "input" ];
}
