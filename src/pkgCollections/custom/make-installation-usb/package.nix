# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2024)
{ pkgs, custom, disko }:

pkgs.resholve.writeScriptBin "make-installation-usb" {
	inputs = [
		custom.bash-preamble.inputForResholve
	];
	interpreter = "${pkgs.bash}/bin/bash";
} ''
	${custom.bash-preamble.preambleForResholve}

	printf -v example_command "%s" \
		'For example, to turn /dev/sda into an installation USB for ' \
		'Jason-Desktop-Linux, run' \
		$'\n\n\tJNC_INSTALLATION_USB=/dev/sda ' \
		'JNC_MACHINE_SLUG=jason-desktop-linux ' \
		"$0"
	readonly example_command
	if [ ! -v JNC_INSTALLATION_USB ]
	then
		echo \
			ERROR: The JNC_INSTALLATION_USB environment variable \
			wasn’t set. Set it to the path to a USB drive. \
			"$example_command" \
			1>&2
		exit 1
	fi
	if [ ! -v JNC_MACHINE_SLUG ]
	then
		echo -E \
			ERROR: The JNC_MACHINE_SLUG environment variable \
			wasn’t set. Set it to the name of one of the \
			directories in src/modules/configuration.nix/, but \
			don’t include the trailing slash at the end. \
			"$example_command" \
			1>&2
		exit 1
	fi
	if [[ "$JNC_MACHINE_SLUG" =~ .*[\"\\\$].* ]]
	then
		echo -E \
			ERROR: The JNC_MACHINE_SLUG environment variable \
			contained a forbidden character. Are you sure that you \
			typed it right? 1>&2
		exit 1
	fi
''
