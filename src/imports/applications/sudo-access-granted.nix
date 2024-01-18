# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2023)
{ config, pkgs ? import <nixpkgs> { } }:

let
	sudo = "${config.security.wrapperDir}/sudo";
in pkgs.resholve.writeScriptBin "sudo" {
	inputs = [
		pkgs.coreutils
	];
	interpreter = "${pkgs.bash}/bin/bash";
	keep."${sudo}" = true;
} ''
	set -e
	console="$(tty)"
	readonly console

	${sudo} -v
	# Sudo normally writes directly to the terminal device instead
	# of writing to stdout, so that’s what I’m doing here
	echo Access granted. &> "$console"
	${sudo} "$@"
''
