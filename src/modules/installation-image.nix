# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
{ config, options, pkgs, lib, modulesPath, ... }:
{
	imports = [
		"${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
	];
	isoImage = {
		isoBaseName = (
			options.isoImage.isoBaseName.default
			+ "-jnc-${config.jnc.machineSlug}"
		);
		appendToMenuLabel = (
			options.isoImage.appendToMenuLabel.default
			+ " (JNC)"
		);
		volumeID = (
			options.isoImage.volumeID.default
			+ "-jnc"
		);
		squashfsCompression = "lz4";
		# Hopefully, this will save the installation target from having
		# to download any additional dependencies in order to build the
		# system configuration.
		includeSystemBuildDependencies = true;
		makeBiosBootable = false;
		makeEfiBootable = true;
	};
	users.users.nixos.packages = let
		pkgCollections = import ../pkgCollections { inherit pkgs lib; };
	in [
		pkgCollections.custom.install-using-jnc
		# This isn’t needed, but it’s useful for debugging.
		pkgCollections.disko.disko
	];
}
