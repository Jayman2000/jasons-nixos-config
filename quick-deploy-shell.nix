# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
{
	pkgs ? import <nixpkgs> {},
	lib ? pkgs.lib
}:

pkgs.mkShell {
	name = "quick-deploy-shell";
	packages = let
		pkgCollections = import src/pkgCollections {
			inherit pkgs lib;
		};
	in [
		pkgs.coreutils
		pkgCollections.custom.deploy-jasons-nixos-config
		pkgCollections.custom.nicely-stop-session
	];
}
