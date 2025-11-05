# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024–2025)
{ pkgs, lib, ... }:
{
	boot.supportedFilesystems = [ "bcachefs" ];
	# Hopefully, this will make my system swap less excessively. See
	# <https://old.reddit.com/r/bcachefs/comments/1d76l99/using_bcachefs_made_my_system_swap_too_much_but_i/>.
	boot.kernel.sysctl."vm.swappiness" = 1;
}
