# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
jncMachineSlug:
{
	imports = let
		modulesPath = "${../.}/modules";
	in [
		"${modulesPath}/install-drive.nix"
		"${modulesPath}/machine-slug.nix"
	];
	jnc.machineSlug = jncMachineSlug;
}
