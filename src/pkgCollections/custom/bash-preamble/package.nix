# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
{ pkgs, custom, lib }:

pkgs.stdenv.mkDerivation (let
	pkgName = "bash-preamble";
	destDir = "share/${pkgName}";
	scriptName = "preamble.sh";
in {
	name = pkgName;
	src = ./.;
	passthru = rec {
		inputForResholve = "${custom."${pkgName}"}/${destDir}";
		preambleForResholve = "source preamble.sh";
		preambleForOthers = ''
			source ${lib.strings.escapeShellArg "${inputForResholve}/preamble.sh"}
		'';
	};
	postInstall = ''
		readonly dest="$out/"${lib.strings.escapeShellArg destDir}
		mkdir -p "$dest"
		cp ${lib.strings.escapeShellArg scriptName} "$dest"
	'';
})
