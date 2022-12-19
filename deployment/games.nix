# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
{ config, pkgs, ... }:
{
	imports = [ ./home-manager.nix ];
	users.users.jayman.packages = with pkgs; [
		chocolateDoom
		ecwolf
		slade
	];
	home-manager.users.jayman = let
		gameDataPath = (
			# TODO: It would be better if this said “if the config.services.syncthing.folders."Game Data" property exists”, but I don’t know how to say that.
			if config.networking.hostName == "Graphical-Test-VM"
			then
				"/var/empty"
			else
				config.services.syncthing.folders."Game Data".path
		);
		doomDataPath = "${gameDataPath}/doom";
		wolf3DDataPath = "${gameDataPath}/Wolfenstien 3D";
	in
	{config, pkgs, ...}: {
		home.sessionVariables.DOOMWADDIR = doomDataPath;
		xdg = {
			enable = true;
			# The mkOutOfStoreSymlnk part ensures that the
			# symlink gets created even if the target
			# doesn’t exist yet. The target won’t exist when
			# a fresh install is done (Syncthing won’t have
			# created the directory yet).
			dataFile.ecwolf.source = config.lib.file.mkOutOfStoreSymlink wolf3DDataPath;
		};
	};
}
