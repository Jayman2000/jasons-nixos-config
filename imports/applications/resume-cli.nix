# SPDX-License-Identifier: LicenseRef-MIT-JY
# SPDX-FileCopyrightText: 2023 Jason Yundt <jason@jasonyundt.email>
{ pkgs ? import <nixpkgs> { }, lib ? pkgs.lib }:

pkgs.buildNpmPackage rec {
	pname = "resume-cli";
	version = "3.0.8";

	src = pkgs.fetchFromGitHub {
		owner = "jsonresume";
		repo = pname;
		rev = "v${version}";
		hash = "sha256-0VikCR2j8b/v9f5haYEwFNypM45R9Z8Y6AgTujaZ8Lg=";
	};

	npmFlags = [ "--legacy-peer-deps" "--loglevel=verbose" ];
	npmDepsHash = "sha256-fwuuglaZ5fdq/w9bn19dbFya/1EDeUe8YhYKqf+X9zI=";

	meta = rec {
		# This was taken from the GitHub repo’s about section.
		description = "CLI tool to easily setup a new resume 📑";
		# This was taken from the GitHub repo’s README.
		longDescription = "This is the command line tool for [JSON Resume](https://jsonresume.org), the open source initiative to create a JSON-based standard for resumes.";
		homepage = "https://github.com/jsonresume/resume-cli";
		downloadPage = "${homepage}/releases";
		changelog = "https://github.com/jsonresume/resume-cli/releases/tag/v${version}";
		license = lib.licenses.mit;
	};
}
