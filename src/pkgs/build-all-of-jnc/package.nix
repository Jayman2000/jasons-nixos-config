# SPDX-FileNotice: 🅭🄍1.0 Unless otherwise noted, everything in this file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-License-Identifier: CC-BY-SA-4.0
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2024)
{
	bash,
	coreutils,
	deploy-jasons-nixos-config,
	jasons-nixos-config,
	resholve
}:

let
	name = "build-all-of-jnc";
in resholve.writeScriptBin name {
	execer = [
		"cannot:${deploy-jasons-nixos-config}/bin/deploy-jasons-nixos-config"
	];
	inputs = [
		deploy-jasons-nixos-config
		coreutils
	];
	interpreter = "${bash}/bin/bash";
} ''
	set -e

	# This is just to work around the fact that “nixos-rebuild build”
	# leaves a result symlink that we don’t want.
	#
	# Thanks you Stewart
	# (https://unix.stackexchange.com/users/272848/stewart) for this Stack
	# Exchange answer: <https://unix.stackexchange.com/a/621294/316181>.
	# That answer available under 🅭🅯🄎4.0:
	# <https://creativecommons.org/licenses/by-sa/4.0/>.
	#
	# BEGIN CC-BY-SA-4.0 LICENSED SECTION
	readonly new_cwd="$(mktemp --directory --suffix=-${name})"
	pushd "$new_cwd"
	function clean_up
	{
		popd
		rm -rf "$new_cwd"
	}
	trap clean_up EXIT
	trap clean_up SIGINT
	# END CC-BY-SA-4.0 LICENSED SECTION

	for file in ${jasons-nixos-config}/modules/configuration.nix/*
	do
		machine_slug="$(basename --suffix=.nix "$file")"
		echo "Building configuration for $machine_slug…"

		# I don’t really want to run “dry-activate” here. I would
		# rather use “build”, but that creates a result symlink, and I
		# don’t want a result symlink.
		env \
			JNC_MACHINE_SLUG="$machine_slug" \
			JNC_NIXOS_REBUILD_AS_ROOT=0 \
			deploy-jasons-nixos-config build --upgrade

		echo "Finished building configuration for $machine_slug."
	done
''
