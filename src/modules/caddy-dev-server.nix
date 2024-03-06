# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
{ pkgs, lib, ... }:
let
	pkgCollections = import ../pkgCollections { inherit pkgs lib; };
	caddy-local-ca-files = pkgCollections.custom.caddy-local-ca-files;
in {
	home-manager.users.jayman = { pkgs, ... }: {
		home.packages = [ pkgs.caddy ];
		xdg.dataFile.caddyLocalCAFiles = {
			target = "caddy/pki/authorities/local";
			source = caddy-local-ca-files;
		};
	};
	security.pki.certificateFiles = [ caddy-local-ca-files ];
}
