# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2024)
#
# This is the post-update hook for Git. See githooks(5) for more information.
{ pkgs }:

pkgs.resholve.writeScriptBin "post-update" {
	execer = [
		# TODO: This can’t be fixed upstream until subparsers
		# are supported. See
		# <https://github.com/abathur/resholve/pull/104>.
		"cannot:${pkgs.git}/bin/git"
	];
	inputs = [ pkgs.git ];
	interpreter = "${pkgs.bash}/bin/bash";
} ''
	exec git update-server-info
''
