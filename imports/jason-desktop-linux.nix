# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
{ config, pkgs, ... }:
{
	imports =
		[
			./home-manager/22.11.nix
			./common.nix
			./efi.nix
			./cli-shortcuts.nix
			./graphical.nix
			./osx-kvm.nix
		];

	networking.hostName = "Jason-Desktop-Linux";
	environment.systemPackages = [
		pkgs.vulkan-tools
		pkgs.wineWowPackages.stable
	];
	time.timeZone = "America/New_York";
	nixpkgs.config.allowUnfree = true;
	programs.steam.enable = true;

	services.syncthing.folders = {
		"Keep Across Linux Distros!".path = "/hdd/home/jayman/Syncthing/.save";
		"Projects".path = "/hdd/home/jayman/Syncthing/Projects";
		"Game Data".path = "/hdd/home/jayman/Syncthing/Game Data";
	};

	# I keep ending up with so little space that I can’t update.
	nix.settings.auto-optimise-store = true;

	# See <https://nixos.org/manual/nixos/stable/#sec-x11>.
	hardware.opengl.driSupport32Bit = true;
}
