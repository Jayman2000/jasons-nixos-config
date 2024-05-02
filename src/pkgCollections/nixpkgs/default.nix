# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
{ lib, customLib, ... }:
let
	nixpkgsInstance = { rev, sha256 ? null }: let
		tarball = customLib.fetchFromGitHubOptionalHash {
			owner = "NixOS";
			repo = "nixpkgs";
			inherit rev sha256;
		};
	in import tarball { };
in {
	unstable = nixpkgsInstance { rev = "nixos-unstable"; };
	lastVersionWithEmacs24 = nixpkgsInstance {
		rev = let
			# Source: <https://github.com/NixOS/nixpkgs/pull/22508>
			commitThatRemovesEmacs24 = (
				"01e44ac1f9af1d42ee9b5000426b780f2a03c948"
			);
		in "${commitThatRemovesEmacs24}^";
		sha256 = "1d25l4gz1wrqcw90s2vvz3v0bnp16gqxaq9pxj55iqj9k28ab7wv";
	};
}
