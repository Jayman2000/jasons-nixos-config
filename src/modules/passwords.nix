# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2024)
{ config, lib, ... }:
{
	users.users = let
		customLib = import ../lib.nix { inherit lib; };
		passwordsDir = "${../.}/generated/passwords/${config.jnc.machineSlug}";
		fileToUserDeclaration = name: value: {
			hashedPasswordFile = "${passwordsDir}/${name}";
		};
		passwordFiles = builtins.readDir passwordsDir;
	in builtins.mapAttrs fileToUserDeclaration passwordFiles;
}
