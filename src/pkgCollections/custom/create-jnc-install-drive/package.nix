# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2024)
{ pkgs, custom, disko, lib }:

let
	name = "create-jnc-install-drive";
	baseDiskConfig = "${custom.jasons-nixos-config}/misc/disko/base-disk-configuration.nix";
	# TODO: I have to preresolve commands here in order to work around this
	# a limitation with resholve [1]. Once that limitation is dealt with
	# upstream, I should stop preresolving commands.
	#
	# [1]: <https://github.com/abathur/resholve/issues/113#issuecomment-1950294690>
	preresolveCommand = (package: commandName:
		lib.strings.escapeShellArg "${package}/bin/${commandName}"
	);
	cpCommand = preresolveCommand pkgs.coreutils "cp";
	diskoCommand = preresolveCommand disko.disko "disko";
	mkdirCommand = preresolveCommand pkgs.coreutils "mkdir";
	nixos-installCommand = (
		preresolveCommand pkgs.nixos-install-tools "nixos-install"
	);
	swapoffCommand = preresolveCommand pkgs.util-linux "swapoff";
	teeCommand = preresolveCommand pkgs.coreutils "tee";
in pkgs.resholve.writeScriptBin name {
	inputs = [
		custom.bash-preamble.inputForResholve
		pkgs.coreutils
		pkgs.findutils
		pkgs.gnugrep
		pkgs.nix
		pkgs.udisks
		pkgs.util-linux
	];
	fake.external = [ "sudo" ];
	execer = [
		# TODO: Once resholve has support for
		# UnlocatedExecCommandParsers [1], then I’ll be able to submit a
		# PR to resholve that makes it so that I don’t have to have an
		# override for udisksctl. Unfortunately, I need to use an
		# UnlocatedExecCommandParser because it’s difficult to determine
		# whether or not “udisksctl mount --options <options>” could
		# contain arguments that get executed.
		#
		# [1]: <https://github.com/abathur/resholve/pull/104#issuecomment-1817775932>
		"cannot:${pkgs.udisks}/bin/udisksctl"
		# TODO: The override for swapon won’t be needed once this issue
		# is fixed: <https://github.com/abathur/binlore/issues/1>.
		"cannot:${pkgs.util-linux}/bin/swapon"
		# TODO: This one probably can’t be fixed in resholve until this
		# issue is dealt with:
		# <https://github.com/abathur/resholve/issues/90>
		"cannot:${pkgs.nix}/bin/nix-instantiate"
	];
	interpreter = "${pkgs.bash}/bin/bash";
} ''
	${custom.bash-preamble.preambleForResholve}

	# These are commands that won’t get resolved by resholve because they’re
	# setuid executables. See
	# <https://github.com/abathur/resholve/issues/29>.
	all_dependencies_found=1
	for dependency in sudo umount
	do
		if ! type "$dependency" > /dev/null
		then
			echo -E \
				"ERROR: The command “$dependency” wasn’t" \
				found. \
				1>&2
			all_dependencies_found=0
		fi
	done
	if [ "$all_dependencies_found" -eq 0 ]
	then
		exit 1
	fi

	# When I use nix-shell to run this script, TMPDIR gets set to
	# /run/user/1000. Later on the the code, this script will create a
	# directory in the TMPDIR, and mount the root filesystem there.
	#
	# Unfortunately, nixos-install requires that the root filesystem’s mount
	# point and all of its parent directories (except for /) have their
	# permissions set to 755 [1].
	#
	# Unfortunately, /run/user/1000 doesn’t have its permissions set to 755,
	# and it probably shouldn’t. As a result, we need to use an alternative
	# TMPDIR that can be given working permissions.
	#
	# [1]: <https://github.com/NixOS/nixpkgs/blob/90055d5e616bd943795d38808c94dbf0dd35abe8/nixos/modules/installer/tools/nixos-install.sh#L93-L102>
	declare -rx TMPDIR=/tmp

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
		exit 2
	fi
	if [ ! -v JNC_INSTALL_DRIVE ]
	then
		echo \
			'ERROR: The JNC_INSTALL_DRIVE environment variable' \
			'wasn’t set. Set it to the block device that will be' \
			'turned into an install dirve (example: /dev/sdx).'
		exit 3
	fi
	readonly config_path="jasons-nixos-config/modules/configuration.nix/$JNC_MACHINE_SLUG/install-drive.nix"
	readonly configuration="{
		imports = [ $config_path ];
		jnc.installDriveDevice = \"$JNC_INSTALL_DRIVE\";
	}"
	readonly swap_size=2G

	working_dir="$(mktemp \
		--directory \
		--suffix=-${lib.strings.escapeShellArg name}
	)"
	readonly working_dir
	printf 'Using “%s” as the working directory. ' "$working_dir"
	echo \
		If this program doesn’t finish successfully, then you will \
		need to delete that directory manually.
	# If I don’t change this directory’s permissions, then nixos-install
	# will give me an error:
	# <https://github.com/NixOS/nixpkgs/blob/90055d5e616bd943795d38808c94dbf0dd35abe8/nixos/modules/installer/tools/nixos-install.sh#L93-L102>
	chmod +rx "$working_dir"
	cd "$working_dir"

	function configuration_looks_valid {
		echo -E "$configuration" > test-configuration.nix
		local result
		result="$(nix-instantiate --eval -E '
			let
				config = import ./test-configuration.nix;
				configPath = builtins.elemAt config.imports 0;
				installDrive = config.jnc.installDriveDevice;
			in (
				builtins.typeOf configPath == "path"
				&& builtins.typeOf installDrive == "string"
			)
		')"
		local -r result
		[ "$result" = true ]
	}
	if ! configuration_looks_valid
	then
		echo \
			ERROR: test-configuration.nix was invalid. This could \
			mean any of the following: \
			1>&2
		echo "" 1>&2
		echo 1. There’s a bug with this script. 1>&2
		echo 2. There’s an invalid character in JNC_MACHINE_SLUG. 1>&2
		echo 3. There’s an invalid character in JNC_INSTALL_DRIVE. 1>&2
		echo "" 1>&2
		echo \
			Please check the values of JNC_MACHINE_SLUG and \
			JNC_INSTALL_DRIVE, and then try again. \
			1>&2
		exit 4
	fi

	mkdir mnt
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
	echo -E "$configuration" \
		| sudo ${teeCommand} mnt/etc/nixos/configuration.nix > /dev/null
	# For whatever reason, if I don’t include the “$PWD/” part before “mnt”,
	# then nixos-install will fail with an error saying that $NIXOS_CONFIG
	# is not an absolute path.
	sudo ${nixos-installCommand} \
		--root "$PWD/mnt" \
		--no-root-password

	echo -E \
		"Installation finished successfully!" \
		"Ejecting $JNC_INSTALL_DRIVE…"
	cd /
	sudo umount --recursive "$working_dir/mnt"
	rm --recursive "$working_dir"

	# Swapoff any partitions what are on $JNC_INSTALL_DRIVE.
	devices_that_depend_on_install_drive="$(
		lsblk --output path --noheadings "$JNC_INSTALL_DRIVE" \
			| tail --lines='+2'
	)"
	readonly devices_that_depend_on_install_drive
	swap_devices="$(swapon --show=name --noheadings)"
	readonly swap_devices
	function is_swap_device {
		echo -E "$swap_devices" \
			| grep --fixed-strings --regexp="$*" > /dev/null
	}
	echo -E "$devices_that_depend_on_install_drive" \
		| while read -r device
		do
			if is_swap_device "$device"
			then
				sudo ${swapoffCommand} "$device"
			fi
		done


	# Eject the install drive:
	function is_loop_device {
		losetup --list --output=name --noheadings \
			| grep --fixed-strings --regexp="$*" > /dev/null
	}
	if is_loop_device "$JNC_INSTALL_DRIVE"
	then
		udisksctl loop-delete --block-device "$JNC_INSTALL_DRIVE"
	else
		udisksctl power-off --block-device "$JNC_INSTALL_DRIVE"
	fi
	echo -E "Successfully ejected $JNC_INSTALL_DRIVE."
''
