# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
{ lib }:

{
	fetchFromGitHubNoHash = { owner, repo, rev }:
		builtins.fetchTarball (
			"https://github.com"
			+ "/${owner}/${repo}"
			+ "/archive/refs/heads/${rev}.tar.gz"
		);

	# Applies function to every directory that’s in path.
	#
	# The result is an attribute set that contains one attribute for
	# each directory in the path. The names of each attribute will
	# be the names of each directory. The values of each attribute
	# will be the result of evaluating
	# (function "dirName" /path/to/dirName/).
	#
	# function should take two arguments, name and path. name is the
	# name of the directory (i.e., what basename gives you). path is
	# the full path to that directory.
	mapSubDirs = function: path: let
		doesAttrReferToDir = (name: value:
			value == "directory"
		);
		dirListingAttrSet = builtins.readDir path;
		dirListingAttrSetOnlyDirs = (
			lib.filterAttrs
			doesAttrReferToDir
			dirListingAttrSet
		);
		replaceValueWithPath = (name: value:
			path + "/${name}"
		);
		dirListingAttrSetWithPaths = (
			builtins.mapAttrs
			replaceValueWithPath
			dirListingAttrSetOnlyDirs
		);
		result = (
			builtins.mapAttrs
			function
			dirListingAttrSetWithPaths
		);
	in
		result;
}
