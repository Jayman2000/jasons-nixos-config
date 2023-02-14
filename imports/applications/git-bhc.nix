# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
with import <nixpkgs> { };

writeShellApplication {
	# Branch HEAD Citation
	name = "git-bhc";
	runtimeInputs = [ git ];
	text = ''
		if [ $# -ne 0 ]; then
			echo "WARNING: No aguments should have been given. Ignoring them…" >&2
		fi
		# If Git decides to use a pager, then the pager will (probably) delete
		# whatever’s on the current line.
		git --no-pager rev-parse --abbrev-ref HEAD | tr -d '\n'
		echo -n " at "
		git --no-pager show -s --pretty=reference
	'';
}
