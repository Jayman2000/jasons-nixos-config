# SPDX-License-Identifier: LicenseRef-MIT-Nixpkgs
# SPDX-FileCopyrightText: 2003-2023 Eelco Dolstra and theNixpkgs/NixOS contributors
# SPDX-FileCopyrightText: 2024 Jason Yundt <jason@jasonyundt.email>
#
# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
	imports =
		[ (modulesPath + "/profiles/qemu-guest.nix")
		];

	boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "virtio_blk" ];
	boot.initrd.kernelModules = [ ];
	boot.kernelModules = [ "kvm-amd" ];
	boot.extraModulePackages = [ ];

	fileSystems."/" =
		{ device = "/dev/disk/by-uuid/ccad31ec-b1bb-4a7b-9d7a-3d71bb9b512c";
			fsType = "ext4";
		};

	fileSystems."/boot" =
		{ device = "/dev/disk/by-uuid/6834-BEAE";
			fsType = "vfat";
		};

	swapDevices =
		[ { device = "/dev/disk/by-uuid/a548bf1b-2727-4c9a-91af-84f142409f5c"; }
		];

	# Enables DHCP on each ethernet and wireless interface. In case of scripted networking
	# (the default) this is the recommended approach. When using systemd-networkd it's
	# still possible to use this option, but it's recommended to use it in conjunction
	# with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
	networking.useDHCP = lib.mkDefault true;
	# networking.interfaces.enp1s0.useDHCP = lib.mkDefault true;

	nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
