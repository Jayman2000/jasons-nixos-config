# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2023)
{
	nixpkgs.overlays = let
		# This PR (<https://github.com/NixOS/nixpkgs/pull/225055>) adds
		# support for the Wooting Two HE.
		url = "https://github.com/jtrees/nixpkgs/archive/refs/heads/update-wooting-udev-rules.tar.gz";
		tarball = builtins.fetchTarball url;
		prNixpkgs = import tarball {};
		overlay = (old: new: {
			wooting-udev-rules = prNixpkgs.wooting-udev-rules;
		});
	in [ overlay ];

	hardware.wooting.enable = true;
	# This is needed for the udev rules to work. See
	# <https://github.com/jtrees/nixpkgs/blob/7918cf7ed4f1c6f8dfc009460a253fe0c6169bf0/nixos/modules/hardware/wooting.nix#L11>.
	users.users.jayman.extraGroups = [ "input" ];
}
