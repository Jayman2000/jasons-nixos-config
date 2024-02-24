# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2024)
{ config, pkgs, ... }:
{
	imports =
		[
			./home-manager/23.11.nix
			./bcachefs.nix
			./disko/jason-laptop-linux.nix
			./common.nix
			./efi.nix
			./graphical.nix
		];

	networking.hostName = "Jason-Laptop-Linux";
	time.timeZone = "America/New_York";

	services.syncthing.folders = {
		"Game Data".path = "/home/jayman/Documents/Home/Syncthing/Game Data";
		"Keep Across Linux Distros!".path = "/home/jayman/Documents/Home/Syncthing/.save";
		Projects.path = "/home/jayman/Documents/Home/Syncthing/Projects";
	};
}
