# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2024)
{
	custom,
	proprietaryGameDataDirectory ? "/var/empty",
	nixpkgs,
	pkgs
}:

pkgs.resholve.writeScriptBin "run-descent3" {
	execer = [
		# TODO: Fix upstream.
		"cannot:${pkgs.lib.meta.getExe nixpkgs.unstable.descent3}"
	];
	inputs = [
		custom.bash-preamble.inputForResholve
		pkgs.coreutils  # for mkdir
		nixpkgs.unstable.descent3
	];
	interpreter = pkgs.lib.meta.getExe pkgs.bash;
} ''
	${custom.bash-preamble.preambleForResholve}
	readonly writable_base_directory=~/D3-open-source
	mkdir --parents "$writable_base_directory"
	exec Descent3 \
		-setdir "$writable_base_directory" \
		-additionaldir ${pkgs.lib.strings.escapeShellArg proprietaryGameDataDirectory}
''
