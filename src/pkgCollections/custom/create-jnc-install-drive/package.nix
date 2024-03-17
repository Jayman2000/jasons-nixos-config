# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2024)
{ pkgs, custom, disko, lib }:

let
	name = "create-jnc-install-drive";
	baseDiskConfig = "${custom.jasons-nixos-config}/misc/disko/base-disk-configuration.nix";
	diskoCommand = lib.strings.escapeShellArg "${disko.disko}/bin/disko";
	# TODO: Create a function that does this for me?
	mkdirCommand = lib.strings.escapeShellArg "${pkgs.coreutils}/bin/mkdir";
	cpCommand = lib.strings.escapeShellArg "${pkgs.coreutils}/bin/cp";
	teeCommand = lib.strings.escapeShellArg "${pkgs.coreutils}/bin/tee";
	nixos-installCommand = lib.strings.escapeShellArg "${pkgs.nixos-install-tools}/bin/nixos-install";
in pkgs.resholve.writeScriptBin name {
	inputs = [
		custom.bash-preamble.inputForResholve
		pkgs.coreutils
	];
	fake.external = [ "sudo" ];
	interpreter = "${pkgs.bash}/bin/bash";
} ''
	${custom.bash-preamble.preambleForResholve}
	set -x

	if [ ! -v JNC_MACHINE_SLUG ]
	then
		echo \
			ERROR: The JNC_MACHINE_SLUG environment variable \
			wasn’t set. Set it to the name of one of the \
			directories in src/modules/configuration.nix/, but \
			don’t include the trailing slash at the end. For \
			example, to build an ISO for Jason-Desktop-Linux, run \
			$'\n\n\tJNC_MACHINE_SLUG=jason-desktop-linux' "$0" \
			1>&2
		exit 1
	fi
	if [ ! -v JNC_INSTALL_DRIVE ]
	then
		echo \
			'ERROR: The JNC_INSTALL_DRIVE environment variable' \
			'wasn’t set. Set it to the block device that will be' \
			'turned into an install dirve (example: /dev/sdx).'
		exit 1
	fi
	# I’ve tried it before, and it looks like
	readonly swap_size=2G
	readonly config_path="jasons-nixos-config/src/modules/$JNC_MACHINE_SLUG/install-drive.nix"

	working_dir="$(mktemp \
		--directory \
		--suffix=-${lib.strings.escapeShellArg name}
	)"
	readonly working_dir
	printf 'Using “%s” as the working directory. ' "$working_dir"
	echo \
		If this program doesn’t finish successfully, then you will \
		need to delete that directory manually.
	cd "$working_dir"

	mkdir mnt
	# TODO: Add comment explaining why I can”t just do “sudo disko”.
	sudo ${diskoCommand} \
		--mode disko \
		--root-mountpoint mnt \
		--argstr swapSize "$swap_size" \
		--argstr deviceName jnc-install-drive \
		--argstr devicePath "$JNC_INSTALL_DRIVE" \
		${lib.strings.escapeShellArg baseDiskConfig}
	sudo ${mkdirCommand} --parents mnt/etc/nixos
	sudo ${cpCommand} \
		--recursive \
		${lib.strings.escapeShellArg custom.jasons-nixos-config} \
		mnt/etc/nixos/jasons-nixos-config
	echo "import $config_path" \
		| sudo ${teeCommand} mnt/etc/nixos/configuration.nix > /dev/null
	sudo ${nixos-installCommand} \
		--option jnc.installDriveDevice "$JNC_INSTALL_DRIVE" \
		--root "$JNC_INSTALL_DRIVE" \
		--no-root-password
	exit 200

	cd /
	rm --recursive "$workding_dir"
''
