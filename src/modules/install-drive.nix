# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
{ config, pkgs, lib, ... }:
let
	diskConfiguration = import ../misc/disko/base-disk-configuration.nix {
		swapSize = "2G";
		deviceName = "jnc-install-drive";
		device = config.jnc.installDriveDevice;
	};
in {
	imports = [
		./bcachefs.nix
		./efi.nix
		./machine-slug.nix
		./unattended-install.nix
	] ++ diskConfiguration.imports;
	options.jnc.installDriveDevice = lib.mkOption {
		type = lib.types.path;
		description = ''
			This should be set to the path to the install drive’s
			block device. This option doesn’t get set anywhere in
			Jason’s NixOS Config. You’ll need to set it by passing
			--option to nixos-install.
		'';
	};
	config = {
		boot = {
			loader.efi.canTouchEfiVariables = lib.mkForce false;
			initrd.availableKernelModules = [
				# I need this module in order to boot from some
				# of the USB drives that I have.
				"uas"
				# I need at least one of these modules to allow
				# VMs to boot the install drive.
				"virtio_pci" "virtio_scsi" "virtio_blk"
			];
		};
		services.getty.autologinUser = "nixos";
		users.users.nixos = {
			isNormalUser = true;
			packages = let
				pkgCollections = import ../pkgCollections {
					inherit pkgs lib;
				};
			in [
				pkgCollections.custom.install-using-jnc
				# This isn’t needed, but it’s useful for
				# debugging.
				pkgCollections.disko.disko
			];
		};
		security.sudo.extraRules = [ {
			users = [ "nixos" ];
			commands = [ {
				command = "ALL";
				options = [ "NOPASSWD" ];
			} ];
		} ];
		specialisation.configToDeploy = {
			configuration = {
				imports = [
					"${../.}/modules/configuration.nix/${config.jnc.machineSlug}"
				];
			};
			inheritParentConfig = false;
		};
		system.stateVersion = "23.11";

		disko = diskConfiguration.disko;
	};
}
