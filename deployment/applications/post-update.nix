# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
#
# This is the post-update hook for Git. See githooks(5) for more information.
with import <nixpkgs> { };

writeShellApplication {
	name = "post-update";
	runtimeInputs = [ git ];
	text = ''
		exec git update-server-info
	'';
}
