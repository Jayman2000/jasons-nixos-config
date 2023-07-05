# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
{
	imports =
		[
			./home-manager/23.05.nix
			./common.nix
			./efi.nix
			./cli-shortcuts.nix
			./graphical.nix
		];
	# Stuff for full disk encryption
	boot.initrd.luks.devices.luksroot = {
		device = "/dev/disk/by-uuid/5a2ba7c1-40d5-47c3-b624-008ffb351e37";
		preLVM = true;
	};

	networking.hostName = "Jason-Laptop-Linux";
	time.timeZone = "America/New_York";
	services.syncthing.folders = {
		"Keep Across Linux Distros!".path = "/home/jayman/Documents/Home/Syncthing/.save";
		"Projects".path = "/home/jayman/Documents/Home/Syncthing/Projects";
		"Game Data".path = "/home/jayman/Documents/Home/Syncthing/Game Data";
	};
	nixpkgs.config.allowUnfree = true;
	programs.steam.enable = true;
}
