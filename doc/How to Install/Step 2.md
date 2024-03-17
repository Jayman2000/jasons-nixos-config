<!--
SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2021–2024)
-->

# 2. Potentially build the NixOS manual

If you’re going to install NixOS 23.05, it’s probably a good idea to follow the
installation instructions in the NixOS 23.05 Manual (as opposed to the
instructions in the manual for the latest version of NixOS). Unfortunately, the
NixOS project isn’t currently distributing built versions of the NixOS 23.05
manual, so we’ll have to build the NixOS 23.05 Manual from source. Here’s how:

1. Make sure that you have [the Nix package
manager](https://nixos.org/manual/nix/stable/) installed.
	You can verify whether or not Nix is installed by running:

		nix-build --version && \
			echo Nix is installed. || \
			echo Nix is not installed.

2. If you don’t already have one, get a local copy of
[the Nixpkgs repo](https://github.com/NixOS/nixpkgs):

		git clone https://github.com/NixOS/nixpkgs.git

3. Change directory into the Nixpkgs repo:

		cd nixpkgs

4. Make sure that you’re looking at the branch that contains the 23.05 version
of the manual:

		git checkout release-23.05

5. Follow the instructions in
`nixos/doc/manual/contributing-to-this-manual.chapter.md`

---

[Previous step](./Step%201.md) [Next step](./Step%203.md)
