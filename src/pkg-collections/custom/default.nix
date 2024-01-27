# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
{ pkgs, lib, customLib }:
# This is a heavily modified version of some code from this post:
# <https://summer.nixos.org/blog/callpackage-a-tool-for-the-lazy/#3-benefit-flexible-dependency-injection>
let
	callPackage = lib.callPackageWith (pkgs // packages);
	dirAttrToPackageAttr = (name: path:
		callPackage (path + "/package.nix") { }
	);
	packages = customLib.mapSubDirs dirAttrToPackageAttr ./.;
in
	packages
