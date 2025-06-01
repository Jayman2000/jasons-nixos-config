# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2024)
{
	imports =
		[
			./home-manager/25.05.nix
			./common.nix
			./bcachefs.nix
			./disko/graphical-test-vm.nix
			./efi.nix
			./cli-shortcuts.nix
			./garbage-collection.nix
			./graphical.nix
			./serial-console.nix
			./sshd.nix
		];
	networking.hostName = "Graphical-Test-VM";
	time.timeZone = "America/New_York";
	services.syncthing.settings.folders = {
		"Keep Across Linux Distros!".path = "/home/jayman/Documents/Home/Syncthing/.save";
	};
}
