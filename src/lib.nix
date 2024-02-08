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
	fetchFromGitHubNoHash = { owner, repo, rev }:
	let
		rootURL = https://github.com/;
		url = rootURL + "${owner}/${repo}/archive/${rev}.tar.gz";
	in
		builtins.fetchTarball url;
}
