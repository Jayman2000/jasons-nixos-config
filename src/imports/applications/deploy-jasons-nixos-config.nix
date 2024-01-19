# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2024)
{
	pkgs ? import <nixpkgs> { },
	jasons-nixos-config ? import ../.. { inherit pkgs; }
}:

pkgs.resholve.writeScriptBin "deploy-jasons-nixos-config" {
	execer = [
		# TODO: This won’t be necessary
		# once this PR is merged:
		# <https://github.com/abathur/binlore/pull/14>
		"cannot:${pkgs.nixos-rebuild}/bin/nixos-rebuild"
	];
	fake.external = [ "sudo" ];
	inputs = [
		pkgs.coreutils
		pkgs.nixos-rebuild
	];
	interpreter = "${pkgs.bash}/bin/bash";
} ''
	set -e

	if ! type sudo &> /dev/null
	then
		echo "ERROR: the sudo command isn’t available."
		exit 1
	fi
	if [ ! -v JNC_MACHINE_SLUG ]
	then
		echo \
			ERROR: The JNC_MACHINE_SLUG environment variable \
			wasn’t set. Set it to the name of one of the files \
			in src/configuration.nix/, but don’t include the .nix \
			at the end. For example, to build the configuration \
			for Jason-Desktop-Linux, \
			$'run\n\n\tJNC_MACHINE_SLUG=jason-desktop-linux' \
			"$0"
		1>&2
		exit 1
	fi
	if [ ! -v JNC_NIXOS_REBUILD_AS_ROOT ]
	then
		echo \
			ERROR: The JNC_NIXOS_REBUILD_AS_ROOT environment \
			variable wasn’t set. Set it to 0 and nixos-rebuild \
			will be run as your local user. Set it to 1 and \
			nixos-rebuild will be run as root. \
		1>&2
		exit 1
	fi
	if ! {
		[ "$JNC_NIXOS_REBUILD_AS_ROOT" -eq 0 ] || \
		[ "$JNC_NIXOS_REBUILD_AS_ROOT" -eq 1 ]
	}
	then
		echo \
			ERROR: The JNC_NIXOS_REBUILD_AS_ROOT environment \
			variable was set to "“$JNC_NIXOS_REBUILD_AS_ROOT”". \
			It should only ever be set to 0 or 1. \
		1>&2
		exit 1
	fi


	declare -xr NIXOS_CONFIG="${jasons-nixos-config}/configuration.nix/$JNC_MACHINE_SLUG.nix"
	# Needed to workaround this issue:
	# <https://github.com/NixOS/nix/issues/3533>
	declare -xr PATH="${pkgs.git}/bin:$PATH"
	if [ "$JNC_NIXOS_REBUILD_AS_ROOT" -eq 0 ]
	then
		nixos-rebuild "$@" --no-build-nix
	else
		sudo --preserve-env=NIXOS_CONFIG,PATH nixos-rebuild "$@" --no-build-nix
	fi
''
