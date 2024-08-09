# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2023)
{ config, pkgs, lib, ... }:
{
	imports =
		[
			./home-manager/24.05.nix
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

	programs.nix-ld = {
		# At work, we recently created an internal documentation site.
		# That site uses the Just the Docs theme [1]. In order to test
		# out a Just the Docs site locally, you need to run “bundle exec
		# jekyll serve” [2]. I tried to get that command to work without
		# nix-ld, but it looked like it would take way too much work, so
		# I’m begrudgingly deciding to enable nix-ld.
		#
		# [1]: <https://just-the-docs.com>
		# [2]: <https://github.com/just-the-docs/just-the-docs-template?tab=readme-ov-file#building-and-previewing-your-site-locally>
		enable = true;

		# I don’t want any libraries to be available to applications by
		# default because I don’t want non-NixOS binaries to work by
		# default. I want to have to explicitly opt-in to running
		# non-NixOS binaries by starting a nix-shell before I run them.
		libraries = lib.mkOverride 50 [ ];
	};
}
