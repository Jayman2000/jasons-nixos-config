# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2024)
{ pkgs, lib, custom }:

let
	name = "start-shell-for-building-gnupg-doc";
in pkgs.resholve.writeScriptBin name {
	fake.external = [ "sudo" ];
	execer = [
		# TODO: I don’t know whether or not nix-shell can execute its
		# arguments, so I don’t even know what should be done about this
		# workaround.
		"cannot:${pkgs.nix}/bin/nix-shell"
	];
	inputs = [
		custom.bash-preamble.inputForResholve
		pkgs.coreutils
		pkgs.nix
	];
	interpreter = "${pkgs.bash}/bin/bash";
	meta = {
		description = "Start a shell that can build GPG’s Web site";
		longDescription = ''
			I want to contribute to GPG’s Web site [1]. GPG’s Web
			site’s build script [2] requires that you have several
			programs installed. Run ${name}, and you’ll have a shell
			with all of those programs installed. It also sets some
			environment variable to (hopefully) make sure that the
			build succeeds.

			[1]: <https://gnupg.org>
			[2]: <https://git.gnupg.org/cgi-bin/gitweb.cgi?p=gnupg-doc.git;a=blob;f=tools/build-website.sh;h=6e2842de4ce7dd7934754e7d64a9ec1573a1665c;hb=HEAD>
		'';
	};
} (let
	jncPath = "${lib.strings.escapeShellArg custom.jasons-nixos-config}";
in ''
	${custom.bash-preamble.preambleForResholve}
	# I want to run the shell with --pure in order to make sure that there
	# are no undelcared dependencies for building gnupg-doc. Running
	# nix-shell with --pure causes nix-shell to clear pretty much all
	# environment variables [1]. That being said, we still want to have the
	# XDG_* variables [2] set because Git uses them. Specifically, Git uses
	# XDG_CONFIG_HOME in order to find its config file. We need Git to find
	# the correct config file. Specifically, we need Git to find its config
	# file in order to set safe.directory. If we don’t set safe.directory,
	# then building gnupg-doc will fail. We make sure that safe.directory
	# gets set in src/modules/build-gpg-web-site.nix.
	#
	# [1]: <man:nix-shell(1)>
	# [2]: <https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html>
	readonly possible_xdg_vars=(
		XDG_DATA_HOME
		XDG_CONFIG_HOME
		XDG_STATE_HOME
		XDG_DATA_DIRS
		XDG_CACHE_HOME
		XDG_RUNTIME_DIR
	)
	for var_name in "''${possible_xdg_vars[@]}"
	do
		if [ -v "$var_name" ]
		then
			declare_commands+=( "$(declare -p "$var_name")" )
		fi
	done
	readonly declare_commands

	sudo_path="$(command -v sudo)"
	readonly sudo_path

	readonly sudo_function="function sudo {
		$(declare -p sudo_path)
		\"\$sudo_path\" \"\$@\"
	} && export -f sudo"

	# Thank you to Adam Katz
	# (https://stackoverflow.com/users/519360/adam-katz) and Charles Duffy
	# (https://stackoverflow.com/users/14122/charles-duffy) for this idea:
	# <https://stackoverflow.com/a/53839433/7593853>
	printf \
		-v minus_minus_command_argument \
		"%s && " \
		"''${declare_commands[@]}"
	# This makes sure that the shell has access to sudo, even if --pure is
	# used.
	minus_minus_command_argument="$minus_minus_command_argument $sudo_function"
	# This makes sure that the user is given a bash prompt. See
	# <man:nix-shell(1)>’s explanation of the --command argument.
	minus_minus_command_argument="$minus_minus_command_argument && return"
	readonly minus_minus_command_argument

	exec nix-shell \
		--command "$minus_minus_command_argument" \
		--argstr jasons-nixos-configPath ${jncPath} \
		"$@" \
		${lib.strings.escapeShellArg ./shell.nix}
'')
