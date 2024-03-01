# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
{
	pkgs ? import <nixpkgs> { },
	lib ? pkgs.lib,
	jasons-nixos-configPath
}:
let
		pkgCollectionsPath = (
			"${jasons-nixos-configPath}/pkgCollections"
		);
		pkgCollections = import pkgCollectionsPath {
			inherit pkgs lib;
		};
		emacs24 = pkgCollections.nixpkgs.lastVersionWithEmacs24.emacs24;
		pathToEmacs24 = "${emacs24}/bin/emacs";
		# gnupg-doc/tools/build-website.sh depends on an executable
		# named emacs24 [1]. Unfortunately, the emacs24 package doesn’t
		# actually have an executable named emacs24, so we have to
		# create one ourselves.
		#
		# [1]: <https://git.gnupg.org/cgi-bin/gitweb.cgi?p=gnupg-doc.git;a=blob;f=tools/build-website.sh;h=6e2842de4ce7dd7934754e7d64a9ec1573a1665c;hb=HEAD#l153>
		emacs24-shim = pkgs.runCommand "emacs24-shim" { } ''
			mkdir -p "$out/bin"
			ln \
				--symbolic \
				${lib.strings.escapeShellArg pathToEmacs24} \
				"$out/bin/emacs24"
		'';
in pkgs.mkShell {
	name = "shell-for-building-gnupg-doc";
	packages = let
		pkgCollectionsPath = (
			"${jasons-nixos-configPath}/pkgCollections"
		);
		pkgCollections = import pkgCollectionsPath {
			inherit pkgs lib;
		};
	in [
		emacs24
		emacs24-shim
		pkgs.gawk
		pkgs.gitFull
		pkgs.procmail
		pkgs.rsync
	];
}
