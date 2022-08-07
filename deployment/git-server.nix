# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
{ config, ... }:
{
	users.groups.git = { };
	users.users.git = {
		description = "Owner of Git repos. git-clone should use this user when cloning over SSH.";
		group = "git";
		isSystemUser = true;

		# Git repos will be stored here. Also needed for the SSH
		# authorized keys file.
		createHome = true;
		home = "/home/git";
	};
}
