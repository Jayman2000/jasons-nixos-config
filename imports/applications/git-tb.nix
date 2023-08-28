# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2023)
with import <nixpkgs> { };

resholve.writeScriptBin "git-tb" {
	execer = [
		# TODO: This can’t be fixed upstream until subparsers
		# are supported. See
		# <https://github.com/abathur/resholve/pull/104>.
		"cannot:${git}/bin/git"
	];
	inputs = [ git ];
	interpreter = "${bash}/bin/bash";
} ''
	subcommand="$1"
	shift

	if [ "$subcommand" = create ]; then
		for branch_name in "$@"; do
			git checkout -b "$branch_name" main &&
			git push -u syncthing
		done
	elif [ "$subcommand" = merge ]; then
		for branch_name in "$@"; do
			git checkout main &&
			git merge --ff-only "$branch_name" &&
			git push &&
			git branch -d "$branch_name" &&
			git push -d syncthing "$branch_name"
		done
	elif [ "$subcommand" = delete ]; then
		for branch_name in "$@"; do
			git branch -D "$branch_name" &&
			git push -d syncthing "$branch_name"
		done
	else
		# shellcheck disable=SC1111
		echo "Unknown subcommand: “$subcommand”"
		exit 1
	fi
''
