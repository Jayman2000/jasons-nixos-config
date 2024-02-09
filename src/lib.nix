# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
{ lib }:
{
	mapSubDirs = function: dir: let
		doesAttrReferToSubDir = (name: value:
			value == "directory"
		);
		dirListing = builtins.readDir dir;
		subDirs = lib.filterAttrs doesAttrReferToSubDir dirListing;
		transformSubDirs = (name: value:
			function "${dir}/${name}"
		);
	in builtins.mapAttrs transformSubDirs subDirs;
	fetchFromGitHubOptionalHash = { owner, repo, rev, sha256 ? null }:
	let
		rootURL = https://github.com/;
		baseArgs = {
			url = rootURL + "${owner}/${repo}/archive/${rev}.tar.gz";
		};
		additionalArgs = (
			if sha256 == null
			then { }
			else { inherit sha256; }
		);
	in builtins.fetchTarball (baseArgs // additionalArgs);
}
