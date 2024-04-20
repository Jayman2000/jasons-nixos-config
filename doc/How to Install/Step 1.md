<!--
SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2021–2024)
-->

# 1. Determine what version of NixOS the config currently expects

You must make sure that you install the appropriate version of NixOS. Each
machine’s config is designed to work with only one version of NixOS.

1. Find the machine-specific config file that contains the information that
we’re looking for.
	- For Jason-Desktop-Linux, this is
	`src/modules/jason-desktop-linux.nix`.

	- For Graphical-Test-VM, this is
	`src/modules/graphical-test-vm.nix`.

	- For `jasonyundt.website.home.arpa`, this is
	`src/modules/jasonyundt.website-common.nix`.
2. Open that file.
3. Look for a line that looks like this:

		./home-manager/<version>.nix

You’ll need to install whatever version of NixOS matches that Home Manager
version. If `<version>` is “22.11” then install NixOS 22.11; If `<version>` is
“23.05” then install NixOS 23.05; If `<version>` is “unstable” then install
NixOS Unstable; etc.

---

[Next step](Step%202.md)
