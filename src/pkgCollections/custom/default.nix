# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
{ pkgs, lib, customLib, pkgCollectionRoot }:
# This is a heavily modified version of some code from this post:
# <https://summer.nixos.org/blog/callpackage-a-tool-for-the-lazy/#3-benefit-flexible-dependency-injection>
let
	argsAvailableToPackages = pkgs // packages // { inherit customLib; };
	callPackage = lib.callPackageWith argsAvailableToPackages;
	pathToPackage = (path:
		callPackage "${path}/package.nix" { }
	);
	packages = customLib.mapSubDirs pathToPackage pkgCollectionRoot;
in
	packages
