# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
{ config, pkgs, ... }:
{
	users.groups.git = { };
	users.users.git = {
		description = "Owner of Git repos. git-clone should use this user when cloning over SSH.";
		group = "git";
		isSystemUser = true;
		shell = "${pkgs.git}/bin/git-shell";

		# Git repos will be stored here. Also needed for the SSH
		# authorized keys file.
		createHome = true;
		home = "/home/git";
		# Any Web (HTTPS, FTP, IPFS, etc.) servers are going to need to
		# be able to read ~git/repos/, but they won’t need to have access
		# to anything else in git’s home folder. ~git/repos/ will have
		# its mode be 740 and users that are supposed to be able to
		# access ~git/repos/ will be added to the git group.
		homeMode = "710";
	};
}
