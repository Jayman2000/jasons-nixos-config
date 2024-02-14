# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
{ config, pkgs, lib, modulesPath, ... }:
{
	imports = [
		"${modulesPath}/installer/cd-dvd/iso-image.nix"
		./machine-slug.nix
	];
	config.systemd = {
		services.unattended-install = let
			dependencies = [ "network-online.target" ];
		in {
			wants = dependencies;
			after = dependencies;
			description = "automatic NixOS installer";
			environment.JNC_MACHINE_SLUG = config.jnc.machineSlug;
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
				set -e
				# This gives install-using-jnc access to
				# sudo.
				export PATH="${config.security.wrapperDir}:$PATH"
				${custom.install-using-jnc}/bin/install-using-jnc
			'';
			serviceConfig = {
				User = "nixos";
				Group = "users";
				# This workaround comes from here:
				# <https://bugzilla.redhat.com/show_bug.cgi?id=1212756#c4>.
				#
				# It won’t be needed once there’s a
				# stable version of Disko that has this
				# PR:
				# <https://github.com/nix-community/disko/pull/535>
				StandardError = "null";
			};
			unitConfig = {
				SuccessAction = "reboot";
				# This allows me to debug if
				# unattended-installer.service doesn’t work.
				OnFailure = "multi-user.target";
			};
		};
		targets.unattended-install = {
			wants = [ "unattended-install.service" ];
			description = "automatic installation environment";
		};
	};
	# This allows us to modify config.isoImage.contents after the rest of
	# the config has set it to something. See
	# <https://github.com/NixOS/nixpkgs/issues/16884#issuecomment-238814281>.
	#
	# Specifically, I want to modify the contents of the ISO so that I can
	# add a custom GRUB entry for doing an unattended install.
	options.isoImage.contents = lib.options.mkOption {
		apply = list: lib.lists.forEach list (item:
			if item.target == "/EFI"
			then item // {
				source = let
					# I chose this name because the original
					# package that I’m modifying is called
					# efi-directory:
					# <https://github.com/NixOS/nixpkgs/blob/ee76c70ea139274f1afd5f7d287c0489b4750fee/nixos/modules/installer/cd-dvd/iso-image.nix#L238>
					pkgName = "efi-directory-customized";
					customizedEfiDir = pkgs.runCommand pkgName {
						nativeBuildInputs = [
							pkgs.buildPackages.grub2_efi
							pkgs.sift
						];
					} ''
						set -e

						mkdir "$out"
						cp -r ${item.source} "$out/EFI"

						grub_cfg="$out/EFI/boot/grub.cfg"
						readonly grub_cfg
						existing_boot_entry="$(
						  echo -n \
							"menuentry 'Unattended Install' "
						  sift \
						    --multiline \
						    --regexp='--class installer\s.*?{.*?}\n' \
						    --only-matching \
						    --limit=1 \
						    "$grub_cfg"
						)"
						readonly existing_boot_entry
						new_boot_entry="$(
						  # Thanks to Cyrus
						  # (https://askubuntu.com/users/336375/cyrus)
						  # for this Ask Ubuntu comment:
						  # <https://askubuntu.com/questions/537967/appending-to-end-of-a-line-using-sed#comment735811_537969>
						  echo -nE "$existing_boot_entry" \
						    | sed 's/linux.*/& systemd.unit=unattended-install.target/'
						)"
						readonly new_boot_entry

						chmod +w "$grub_cfg"
						echo -nE "$new_boot_entry" \
							>> "$grub_cfg"
						chmod -w "$grub_cfg"

						grub-script-check "$grub_cfg"
					'';
				in "${customizedEfiDir}/EFI";
			}
			else item
		);
	};
}
