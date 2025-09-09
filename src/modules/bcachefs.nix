# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024–2025)
{ pkgs, lib, ... }:
{
	boot.supportedFilesystems = [ "bcachefs" ];
	# At the moment, pkgs.linux gives you Linux 6.6.92 [1]. Bcachefs didn’t
	# make it into the kernel until Linux 6.7 [2]. That’s why we have to
	# tell it to use a newer kernel here. Also, we have to use mkForce here
	# because src/modules/installation-image.nix imports another module
	# that has a conflicting value for
	# boot.kernelPackages.
	#
	# Unfortunately, I can’t just use any kernel version that’s greater
	# than or equal to 6.7. Specifically, I tried using Linux 6.12.x, and
	# it made Jason-Desktop-Linux take over five hours to boot. I want to
	# switch back to NixOS’s default Linux kernel version, but I can’t
	# until the default Linux kernel version is greater than or equal to
	# 6.14 (I haven’t done extensive testing, but I believe that 6.14 is
	# the first version of Linux where my desktop will take less than five
	# hours to boot).
	#
	# With all of that in mind, here’s the process that should be followed
	# whenever the Linux kernel version is changed:
	#
	# 1. Check to see if NixOS’s default version of Linux is greater than
	# or equal to 6.14. If it is, then make this next line use the default
	# version of Linux.
	#
	# 2. Check <https://www.kernel.org/category/releases.html> to see if
	# there’s any LTS kernels with version numbers greater than or equal to
	# 6.14. If there are, then use the LTS kernel with the lowest version
	# number that’s greater than or equal to 6.14.
	#
	# 3. Otherwise, use the kernel that’s in Nixpkgs that has the lowest
	# version number that’s greater than or equal to 6.14.
	#
	# [1]: <https://web.archive.org/web/20250531104125/https://search.nixos.org/packages?channel=24.11&show=linux&from=0&size=50&sort=relevance&type=packages&query=linux>
	# [2]: <https://lore.kernel.org/lkml/CAHk-=widprp4XoHUcsDe7e16YZjLYJWra-dK0hE1MnfPMf6C3Q@mail.gmail.com/>
	boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_16;
	# Hopefully, this will make my system swap less excessively. See
	# <https://old.reddit.com/r/bcachefs/comments/1d76l99/using_bcachefs_made_my_system_swap_too_much_but_i/>.
	boot.kernel.sysctl."vm.swappiness" = 1;
}
