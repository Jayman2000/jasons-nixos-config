# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2023)
{ config, lib, pkgs, ... }:
{
	imports = [
		./home-manager/23.05.nix
		./common.nix
		./auto-upgrade.nix
		./knot-dns.nix
		./tmpfs-and-swap.nix
		./self-test.nix
	];

	# This is an annoying workaround. When I run
	# “sudo nixos-rebuild boot --install-bootloader”, I get this
	# error:
	#
	#   grub-install: error: cannot find a GRUB drive for /dev/vda.  Check your device.map.
	#
	# That error indicates that there’s two problems:
	# 1. We’re trying to install GRUB to a device that doesn’t
	# exist.
	# 2. We aren’t using a persistent block device name [1].
	#
	# Ideally, I would just install GRUB to
	# /dev/disk/by-uuid/<whatever>, but there was nothing in that
	# directory for the disk itself (there was only a symlink for
	# the partition). OK, what about /dev/by-label? Nope, the
	# partition table can’t have a label [2]. OK, what about
	# /dev/disk/by-id? Nope, that directory doesn’t exist on this
	# machine. OK, what about /dev/disk/by-path? Nope, that
	# directory also doesn’t exist.
	#
	# There is a directory named /dev/disk/by-diskseq which I had
	# never heard of before, but disk sequence numbers aren’t
	# persistent. For example, let’s say that you plug a USB drive
	# in, at it’s assigned disk sequence number 11. Then, you unplug
	# the USB drive, and plug it back in. Now, its disk
	# sequence number will be higher than 11, and there will be no
	# disk with sequence number 11 [3].
	#
	# Apparently, the disk itself appears in /dev/disk/by-partuuid
	# on some peoples systems [4] (even though it’s not a
	# partition), but it’s not there for me.
	#
	# As a result, I’m adding a udev rule that will create a
	# persistent symlink for me. I’m not putting it in one of the
	# usual directories so that it doesn’t end up overwriting a
	# different rule. (I’m hoping that one day I’ll do an update
	# that will make something appear in /dev/disk/by-uuid. If that
	# happens, then I won’t need this extra udev rule anymore.)
	#
	# [1]: <https://wiki.archlinux.org/title/Persistent_block_device_naming>
	# [2]: <https://unix.stackexchange.com/q/528816/316181>
	# [3]: <https://docs.kernel.org/admin-guide/abi-stable.html?highlight=diskseq#abi-sys-block-disk-diskseq>
	# [4]: <https://old.reddit.com/r/linuxquestions/comments/smbkok/using_hdparm_by_ptuuid/hvvmcm9/>
	services.udev.extraRules = ''
		ENV{DEVTYPE}=="disk", ENV{ID_PART_TABLE_UUID}=="?*", SYMLINK+="disk/by-ptuuid/$env{ID_PART_TABLE_UUID}"
	'';
	boot.loader.grub.device = lib.mkForce "/dev/disk/by-ptuuid/288cec8b";

	# The server itself is in Paris, but I’ll be using it from
	# computers in America, so no timezone quite makes sense here.
	time.timeZone = "Etc/UTC";

	# The goal here is to make networking.fqdn accurate.
	networking.hostName = "mailserver";
	networking.domain = "test.jasonyundt.email";

	users.users.jayman.openssh.authorizedKeys.keys = [
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGOkLREBd8ijpssLjYJABnPiAEK11+uTkalt1qO3UntX jayman@Jason-Desktop-Linux"
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICZ+H6hJgs+SQVcRkTgmtHBkh0Fz9KFicmWih8qAA3Mb jayman@Jason-Laptop-Linux"
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAxhFrE4xzbbctfKmM731F3SEAilbltANP4J8WQhIAIb jayman@Jason-Lemur-Pro"
	];

	# The LAN for Gandicloud VPS doesn’t seem to advertise IPv6 DNS
	# recursive resolver addresses. I’m also adding some IPv4
	# addresses here as a back up.
	networking.nameservers = let
		recursiveResolvers = import ./recursive-resolvers.nix;
	in builtins.concatLists [
		recursiveResolvers.expectedARecords
		recursiveResolvers.expectedAAAARecords
	];
}
