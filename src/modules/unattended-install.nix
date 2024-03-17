# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
{ config, pkgs, lib, ... }:
let
	pkgCollections = import ../pkgCollections {
		inherit pkgs lib;
	};
	preamble = pkgCollections.custom.bash-preamble.preambleForOthers;
in {
	imports = [
		./machine-slug.nix
	];
	systemd = {
		services = {
			dump-journal = {
				description = "Installation Log Copier";
				path = [
					# These are required for nixos-enter to
					# work.
					pkgs.util-linux
				];
				script = let
					nixos-enter-package = (
						config.system.build.nixos-enter
					);
					nixos-enter = "${nixos-enter-package}/bin/nixos-enter";
				in ''
					${preamble}
					readonly mount_point=/mnt
					readonly roots_home="$(
						${nixos-enter} \
							--root "$mount_point" \
							--command "printf %s ~root"
					)"
					readonly dest="$mount_point/$roots_home/install.exported_journal"
					journalctl --output=export > "$dest"
				'';
				serviceConfig = {
					StandardOutput = "journal+console";
					StandardError = "journal+console";
				};
				unitConfig = {
					SuccessAction = "reboot";
					OnFailure = "multi-user.target";
				};
			};
			unattended-install = let
				dependencies = [ "network-online.target" ];
			in {
				wants = dependencies;
				after = dependencies;
				description = "automatic NixOS installer";
				environment.JNC_MACHINE_SLUG = (
					config.jnc.machineSlug
				);
				path = [
					# install-using-jnc runs disko, and
					# disko needs commands from these
					# packages to be in the user’s PATH.
					pkgs.nix
				];
				script = let
					pkgCollections = import ../pkgCollections {
						inherit pkgs lib;
					};
					custom = pkgCollections.custom;
				in ''
					${preamble}
					# This gives install-using-jnc access to
					# sudo.
					export PATH="${config.security.wrapperDir}:$PATH"
					${custom.install-using-jnc}/bin/install-using-jnc
				'';
				serviceConfig = {
					User = "nixos";
					Group = "users";
					StandardOutput = "journal+console";
					StandardError = "journal+console";
				};
				unitConfig = {
					OnSuccess = "dump-journal.service";
					# This allows me to debug if
					# unattended-installer.service
					# doesn’t work.
					OnFailure = "multi-user.target";
				};
			};
		};
		targets.unattended-install = {
			wants = [ "unattended-install.service" ];
			description = "automatic installation environment";
		};
	};
	specialisation.unattendedInstall.configuration.boot.kernelParams = [
		"systemd.unit=unattended-install.target"
	];
}
