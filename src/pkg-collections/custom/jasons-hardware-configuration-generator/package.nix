# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2024)
{
	bash,
	coreutils,
	git,
	nixos-install-tools,
	resholve
}:


resholve.writeScriptBin "jasons-hardware-configuration-generator" {
	execer = [
		# TODO: This won’t be needed once this PR is completed:
		# <https://github.com/abathur/binlore/pull/15>.
		"cannot:${nixos-install-tools}/bin/nixos-generate-config"
	];
	inputs = [
		coreutils
		git
		nixos-install-tools
	];
	interpreter = "${bash}/bin/bash";
} ''
	set -e

	if [ ! -v JNC_MACHINE_SLUG ]
	then
		echo \
			ERROR: The JNC_MACHINE_SLUG environment variable \
			wasn’t set. Set it to the name of one of the files \
			in src/modules/configuration.nix/, but don’t include \
			the .nix at the end. For example, to generate a \
			hardware configuration for Jason-Desktop-Linux, \
			$'run\n\n\tJNC_MACHINE_SLUG=jason-desktop-linux' \
			"$0"
		1>&2
		exit 1
	fi

	function print_spdx_metadata
	{
		# I broke this up into multiple echo commands to prevent a very
		# specific problem. If I had just written “echo <spdx-tag>”,
		# then tools might think that that tag applies to this script.
		# It’s not supposed to apply to this file. It’s supposed to
		# apply to the file that this script generates.
		echo -n "# SPDX-"
		echo License-Identifier: LicenseRef-MIT-Nixpkgs

		echo -n "# SPDX-"
		echo -n FileCopyrightText: 2003-2023 Eelco Dolstra and the
		echo Nixpkgs/NixOS contributors

		echo -n "# SPDX-"
		echo -n FileCopyrightText: "$(date +%Y)" Jason Yundt
		echo ' <jason@jasonyundt.email>'

		echo "#"
	}

	readonly output="./$JNC_MACHINE_SLUG.nix"
	{
		print_spdx_metadata
		nixos-generate-config --show-hardware-config
	} | unexpand --tabs=2 --first-only > "$output"
''
