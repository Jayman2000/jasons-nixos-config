# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
{ pkgs ? import <nixpkgs> {} }:

let
	deploy-jasons-nixos-config = import ./src/imports/applications/deploy-jasons-nixos-config.nix { inherit pkgs; };
	nicely-stop-session = import ./src/imports/applications/nicely-stop-session.nix { inherit pkgs; };
in
pkgs.mkShell {
	name = "deploy-shell";
	packages = [
		deploy-jasons-nixos-config
		nicely-stop-session
	];
	shellHook = ''
		deploy-jasons-nixos-config && nicely-stop-session "$session_stop_type"
		exit
	'';
}