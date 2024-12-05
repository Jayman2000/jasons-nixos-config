# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2023)
{ config, pkgs, ... }:
{
	imports =
		[
			./home-manager/24.11.nix
			./bcachefs.nix
			./common.nix
			./efi.nix
			./cdemu.nix
			./cli-shortcuts.nix
			./graphical.nix
			./mouse-configuration-utility.nix
			./periodically-build-all-of-jnc.nix
			./printing.nix
			./osx-kvm.nix
			./sshd.nix
			./tf2-tcmalloc-fix.nix
			./wooting.nix
		];

	networking.hostName = "Jason-Desktop-Linux";
	environment.systemPackages = [ pkgs.vulkan-tools ];
	time.timeZone = "America/New_York";
	nixpkgs.config.allowUnfree = true;
	hardware.steam-hardware.enable = true;
	programs.steam.enable = true;

	services.syncthing.settings.folders = {
		"Keep Across Linux Distros!".path = "/hdd/home/jayman/Syncthing/.save";
		"Projects".path = "/hdd/home/jayman/Syncthing/Projects";
		"Game Data".path = "/hdd/home/jayman/Syncthing/Game Data";
	};

	# I keep ending up with so little space that I can’t update.
	nix.settings.auto-optimise-store = true;

	services.davfs2.enable = true;
}
