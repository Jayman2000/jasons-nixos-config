# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
{ pkgs ? import <nixpkgs> {} }:

let
	jasons-hardware-configuration-generator = import ../imports/applications/jasons-hardware-configuration-generator.nix { inherit pkgs; };
in
pkgs.mkShell {
	name = "deploy-shell";
	packages = [
		jasons-hardware-configuration-generator
	];
	shellHook = ''
		jasons-hardware-configuration-generator
		exit
	'';
}
