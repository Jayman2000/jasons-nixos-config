# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
{
	jasons-nixos-config,
	nixos
}:

let
	configuration = "${jasons-nixos-config}/modules/configuration.nix/installation-image.nix";
	nixOSPackage = nixos configuration;
in
	nixOSPackage.config.system.build.isoImage
