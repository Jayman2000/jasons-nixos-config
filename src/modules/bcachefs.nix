# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
{ pkgs, lib, ... }:
{
	boot.supportedFilesystems = [ "bcachefs" ];
	# At the moment, pkgs.linux gives you Linux 6.1.81 [1]. Bcachefs didn’t
	# make it into the kernel until Linux 6.7 [2]. That’s why we have to
	# tell it to use a newer kernel here. Also, we have to use mkForce here
	# because src/modules/installation-image.nix imports another module
	# that has a conflicting value for
	# boot.kernelPackages.
	#
	# Previously, I had set boot.kernelPackages to
	# pkgs.linuxPackages_latest. I’m temporarily setting it to
	# pkgs.linuxKernel.packages.linux_6_7 in order to workaround this bug
	# [3].
	#
	# [1]: <https://web.archive.org/web/20240313213107/https://search.nixos.org/packages?channel=23.11&show=linux&from=0&size=50&sort=relevance&type=packages&query=linux>
	# [2]: <https://lore.kernel.org/lkml/CAHk-=widprp4XoHUcsDe7e16YZjLYJWra-dK0hE1MnfPMf6C3Q@mail.gmail.com/>
	# [3]: <https://github.com/NixOS/nixpkgs/issues/295717>
	boot.kernelPackages = lib.mkForce pkgs.linuxKernel.packages.linux_6_7;
}
