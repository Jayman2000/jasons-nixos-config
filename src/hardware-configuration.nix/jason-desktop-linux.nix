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
		[ (modulesPath + "/installer/scan/not-detected.nix")
		];

	boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "sd_mod" ];
	boot.initrd.kernelModules = [ ];
	boot.kernelModules = [ "kvm-amd" ];
	boot.extraModulePackages = [ ];

	fileSystems."/" =
		{ device = "/dev/disk/by-uuid/98776a1c-5483-4d5d-9179-af0493a16456";
			fsType = "ext4";
		};

	fileSystems."/boot" =
		{ device = "/dev/disk/by-uuid/B007-79D2";
			fsType = "vfat";
		};

	fileSystems."/hdd" =
		{ device = "/dev/disk/by-uuid/d756625b-6fef-432f-aed8-6edd23825f64";
			fsType = "ext4";
		};

	swapDevices =
		[ { device = "/dev/disk/by-uuid/2431450a-c7cc-4ef6-82ab-a6dc39cbca81"; }
		];

	# Enables DHCP on each ethernet and wireless interface. In case of scripted networking
	# (the default) this is the recommended approach. When using systemd-networkd it's
	# still possible to use this option, but it's recommended to use it in conjunction
	# with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
	networking.useDHCP = lib.mkDefault true;
	# networking.interfaces.docker0.useDHCP = lib.mkDefault true;
	# networking.interfaces.enp8s0.useDHCP = lib.mkDefault true;
	# networking.interfaces.virbr0.useDHCP = lib.mkDefault true;

	nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
	hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
