# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
{ config, pkgs, ... }:
{
	imports =
		[
			./efi.nix
			./cli-shortcuts.nix
			./graphical.nix
		];

	networking = {
		hostName = "Jason-Desktop-Linux";
		interfaces.enp8s0.useDHCP = true;
	};
	environment.systemPackages = [ pkgs.vulkan-tools ];
	time.timeZone = "America/New_York";
        nixpkgs.config.allowUnfree = true;
        programs.steam.enable = true;

	home-manager.users.jayman = { pkgs, ... }: {
		home.packages = [ pkgs.transmission-qt ];
	};
}
