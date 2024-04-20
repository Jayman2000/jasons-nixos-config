# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
#
# This file contains any configuration changes that I need to make in order to
# allow me to build Descent 3 [1] from source.
#
# [1]: <https://github.com/DescentDevelopers/Descent3>
{ pkgs, lib, ... }:
{
	nixpkgs.overlays = [
		(self: super: {
		})
	];
	programs.nix-ld = {
		enable = true;
		# The version of nix-ld that’s in nixos-23.11 is 1.2.2 [1].
		# Unfortunately, that version doesn’t work on 32-bit systems
		# [2][3], so we’re getting a newer version from nixos-unstable.
		# We need 32-bit support because Descent 3 tries to run a 32-bit
		# binary as part of its build process [4].
		#
		# [1]: <https://github.com/NixOS/nixpkgs/blob/nixos-23.11/pkgs/os-specific/linux/nix-ld/default.nix#L15>
		# [2]: <https://github.com/NixOS/nixpkgs/blob/nixos-23.11/pkgs/os-specific/linux/nix-ld/default.nix#L58>
		# [3]: <https://github.com/Mic92/nix-ld/releases/tag/1.2.3>
		# [4]: <https://github.com/DescentDevelopers/Descent3/issues/61>
		package = let
			pkgCollections = import ../pkgCollections {
				inherit pkgs lib;
			};
			unstablePkgs = pkgCollections.nixpkgs.unstable;
		in unstablePkgs.pkgsi686Linux.nix-ld;
	};
}
