# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2023–2024)
{ config, pkgs, ... }:

let
	realSudo = "${config.security.wrapperDir}/sudo";
	customSudo = pkgs.resholve.writeScriptBin "sudo" {
		inputs = [
			pkgs.coreutils
		];
		interpreter = "${pkgs.bash}/bin/bash";
		keep."${realSudo}" = true;
	} ''
		set -e
		console="$(tty)"
		readonly console

		${realSudo} -v
		# Sudo normally writes directly to the terminal device instead
		# of writing to stdout, so that’s what I’m doing here
		echo Access granted. &> "$console"
		${realSudo} "$@"
	'';
in {
	environment.systemPackages = [ customSudo ];
	users.users.jayman.extraGroups = [ "wheel" ];
	# Make sure that running “sudo” runs our custom sudo instead of
	# the regular one.
	environment.shellInit = ''
		PATH="${customSudo}/bin:$PATH"
	'';
}
