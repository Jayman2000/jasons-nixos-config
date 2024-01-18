# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
{ pkgs ? import <nixpkgs> {} }:

let
	deploy-script = import ./imports/applications/deploy.nix { inherit pkgs; };
in
pkgs.mkShell {
	name = "deploy-shell";
	packages = [
		deploy-script
	];
	shellHook = ''
		deploy
		exit
	'';
}
