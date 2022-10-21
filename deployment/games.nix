# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
{ config, pkgs, ... }:
{
	imports = [ ./home-manager.nix ];
	users.users.jayman.packages = with pkgs; [
		ecwolf  # TODO: Declaratively specify base game data location
		slade
	];
}