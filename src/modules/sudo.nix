# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2023–2024)
{ config, pkgs, lib, ... }:

let
	pkgCollections = import ../pkgCollections { inherit pkgs lib; };
	realSudo = "${config.security.wrapperDir}/sudo";
	realSudoCommand = lib.strings.escapeShellArg realSudo;
	customSudo = pkgs.resholve.writeScriptBin "sudo" {
		inputs = [
			pkgCollections.custom.bash-preamble.inputForResholve
			pkgs.coreutils
		];
		interpreter = "${pkgs.bash}/bin/bash";
		keep."${realSudo}" = true;
	} ''
		${pkgCollections.custom.bash-preamble.preambleForResholve}
		console="$(tty)"
		readonly console

		${realSudoCommand} -v
		# Sudo normally writes directly to the terminal device instead
		# of writing to stdout, so that’s what I’m doing here
		echo Access granted. &> "$console"
		${realSudoCommand} "$@"
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
