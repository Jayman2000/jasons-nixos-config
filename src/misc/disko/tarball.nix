# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
{ lib ? null, customLib ? import ../../lib.nix { inherit lib; } }:
customLib.fetchFromGitHubOptionalHash {
	owner = "nix-community";
	repo = "disko";
	rev = "v1.9.0";
	sha256 = "0j76ar4qz320fakdii4659w5lww8wiz6yb7g47npywqvf2lbp388";
}
