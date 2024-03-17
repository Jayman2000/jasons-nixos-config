# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2023–2024)
{ config, pkgs, lib, ... }:

let
	pkgCollections = import ../pkgCollections { inherit pkgs lib; };
	bash-preamble = pkgCollections.custom.bash-preamble;
	realSudo = "${config.security.wrapperDir}/sudo";
	realSudoCommand = lib.strings.escapeShellArg realSudo;
	customSudo = pkgs.resholve.writeScriptBin "sudo" {
		inputs = [
			bash-preamble.inputForResholve
			pkgs.coreutils
		];
		interpreter = "${pkgs.bash}/bin/bash";
		keep."${realSudo}" = true;
	} ''
		${bash-preamble.preambleForResholve}
		# Only try to do the access granted thing if we’re connected to
		# a terminal. When we aren’t connected to a terminal, tty will
		# print “not a tty” [1].
		#
		# [1]: <https://www.gnu.org/software/coreutils/manual/html_node/tty-invocation.html#tty-invocation>
		if console="$(tty)"
		then
			# We group all of these commands using curly brackets so
			# that we can redirect the stdin for all of them. We
			# don’t want them to use the real stdin, or else they’ll
			# read from stdin. The only command that should read
			# from stdin is the final command at the bottom of the
			# script. If any other command reads from stdin, then
			# stuff like “echo contents | sudo tee file.txt” won’t
			# work.
			{
				readonly console
				${realSudoCommand} -v
				# Sudo normally writes directly to the terminal
				# device instead of writing to stdout, so that’s
				# what I’m doing here
				echo Access granted. &> "$console"
			} </dev/null
		fi
		exec ${realSudoCommand} "$@"
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
