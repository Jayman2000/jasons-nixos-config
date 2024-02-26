# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2024)
{ pkgs, custom }:

pkgs.resholve.writeScriptBin "build-jnc-install-iso" {
	execer = [
		"cannot:${pkgs.nix}/bin/nix-build"
	];
	inputs = [
		custom.bash-preamble.inputForResholve
		pkgs.nix
		pkgs.coreutils
	];
	interpreter = "${pkgs.bash}/bin/bash";
} ''
	${custom.bash-preamble.preambleForResholve}

	if [ ! -v JNC_MACHINE_SLUG ]
	then
		echo \
			ERROR: The JNC_MACHINE_SLUG environment variable \
			wasn’t set. Set it to the name of one of the \
			directories in src/modules/configuration.nix/, but \
			don’t include the trailing slash at the end. For \
			example, to build an ISO for Jason-Desktop-Linux, run \
			$'\n\n\tJNC_MACHINE_SLUG=jason-desktop-linux' "$0" \
			1>&2
		exit 1
	fi
	if [[ "$JNC_MACHINE_SLUG" =~ .*[\"\\\$].* ]]
	then
		echo \
			ERROR: The JNC_MACHINE_SLUG environment variable \
			contained a forbidden character. Are you sure that you \
			typed it right? 1>&2
		exit 1
	fi

	mkdir -p ISOs
	readonly attribute="custom.jnc-install-iso.\"$JNC_MACHINE_SLUG\""
	nix-build \
		"${custom.jasons-nixos-config}/pkgCollections" \
		-A "$attribute" \
		--out-link "ISOs/$JNC_MACHINE_SLUG" \
		"$@"
''
