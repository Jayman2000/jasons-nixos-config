# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
{ lib, customLib, ... }:
let
	nixpkgsInstance = { owner ? "NixOS", rev, sha256 ? null }: let
		tarball = customLib.fetchFromGitHubOptionalHash {
			repo = "nixpkgs";
			inherit owner rev sha256;
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
	# <https://github.com/NixOS/nixpkgs/pull/305046>
	pr305046 = nixpkgsInstance {
		owner = "bendlas";
		rev = "257c1a231ed8b02b8e8196600cce2f09b1f61783";
		sha256 = "0mwg9qxpgiriab9lr0cjxpan25dn63pb5kbydzdxy1ihs7x5f2aj";
	};
}
