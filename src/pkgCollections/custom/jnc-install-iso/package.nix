# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
{ pkgs, custom, customLib }:

let
	pathToISO = path: let
		configuration = "${path}/installation-image.nix";
		nixOSPackage = pkgs.nixos configuration;
	in
		nixOSPackage.config.system.build.isoImage;
in
	customLib.mapSubDirs pathToISO "${custom.jasons-nixos-config}/modules/configuration.nix"
