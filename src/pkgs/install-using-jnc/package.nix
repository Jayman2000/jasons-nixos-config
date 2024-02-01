# SPDX-FileNotice: 🅭🄍1.0 Unless otherwise noted, everything in this file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-License-Identifier: CC-BY-SA-4.0
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2024)
{
	bash,
	jasons-hardware-configuration-generator,
	jasons-nixos-config,
	nixos-install-tools,
	resholve
}:

resholve.writeScriptBin "install-using-jnc" {
	inputs = [ nixos-install-tools ];
	fake.external = [ "sudo" ];
	interpreter = "${bash}/bin/bash";
} ''
	set -eu

	if ! type sudo &> /dev/null
	then
		echo "ERROR: the sudo command isn’t available." 1>&2
		exit 1
	fi
	if [ ! -v JNC_MACHINE_SLUG ]
	then
		echo \
			ERROR: The JNC_MACHINE_SLUG environment variable \
			wasn’t set. Set it to the name of one of the files \
			in src/modules/configuration.nix/, but don’t include \
			the .nix at the end. For example, to install using the \
			configuration for Jason-Desktop-Linux, \
			$'run\n\n\tJNC_MACHINE_SLUG=jason-desktop-linux' \
			"$0" 1>&2
		exit 1
	fi

	readonly import_basedir=./src/modules/configuration.nix
	readonly config="import $import_basedir/$JNC_MACHINE_SLUG.nix"
	# After the installation is finished, we won’t need /etc/nixos.
	readonly temporary_config_dir="/mnt/etc/nixos"
	function clean_up {
		echo Cleaning up…
		cd /
		sudo rm --recursive --force "$temporary_config_dir"
	}
	trap clean_up EXIT
	trap clean_up SIGINT

	function sudo_write {
		local -r to_write="$1"
		shift
		echo "$to_write" | sudo tee "$*" > /dev/null
	}

	sudo mkdir -p "$temporary_config_dir"
	readonly dest="$temporary_config_dir/src"
	sudo cp --recursive --remove-destination \
		"${jasons-nixos-config}" \
		"$dest"
	cd "$temporary_config_dir"
	# This prevents jasons-hardware-configuration-generator from silently
	# failing. If for whatever reason
	# jasons-hardware-configuration-generator does not write a new hardware
	# configuration file, then this command will make it so that
	# nixos-install fails.
	sudo rm "$dest/modules/hardware-configuration.nix/$JNC_MACHINE_SLUG.nix"
	sudo \
		--preserve-env=JNC_MACHINE_SLUG \
		JNC_INSTALLING=1 \
		"${jasons-hardware-configuration-generator}/bin/jasons-hardware-configuration-generator"
	sudo_write "$config" "$temporary_config_dir/configuration.nix"

	cd /
	sudo nixos-install
''
