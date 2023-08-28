# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2023)
with import <nixpkgs> { };

resholve.writeScript "deploy" {
	execer = [
		# TODO: This won’t be needed once this PR is completed:
		# <https://github.com/abathur/resholve/pull/104>
		"cannot:${flatpak}/bin/flatpak"
	];
	fake.external = [ "sudo" ];
	inputs = [
		coreutils
		flatpak
		nixos-rebuild
	];
	interpreter = "${bash}/bin/bash";
} ''
	set -e

	if ! type sudo &> /dev/null
	then
		echo "ERROR: the sudo command isn’t available."
		exit 1
	fi

	readonly config_dir="/etc/nixos"
	readonly imports_dir="$config_dir/imports"

	function copy_and_restrict {
		# Usage: copy_and_restrict <mode> <file> [file]…
		local -r mode="$1"
		shift
		sudo cp -r "$@" "$config_dir"
		for src in "$@"; do
			local dest="$config_dir/$src"
			sudo chown -R root:root "$dest"
			sudo chmod -R "$mode" "$dest"
		done
	}

	if [ -e "$imports_dir" ]
	then
		sudo rm -r "$imports_dir"
	fi

	copy_and_restrict u=X,g=,o= imports/
	declare -a args
	if [ "$switch" = yes ]; then
		args=( switch )
	else
		args=( boot --upgrade )
	fi

	# Needed to workaround this issue:
	# <https://github.com/NixOS/nix/issues/3533>
	readonly path_with_git="${git}/bin:$PATH"
	sudo PATH="$path_with_git" nixos-rebuild "''${args[@]}" --no-build-nix

	if [ "$switch" != yes ]
	then
		# Assume that the user is trying to upgrade the system.
		flatpak update --noninteractive
	fi
''
