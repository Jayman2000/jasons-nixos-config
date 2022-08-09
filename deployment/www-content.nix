# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
{ config, ... }:
{
	users.groups.www-content = { };
	users.users.www-content = {
		description = "This user’s home directory is where content served by Web servers is stored.";
		group = "www-content";
		isSystemUser = true;

		createHome = true;
		home = "/home/www-content";
		# Web servers are going to need to be able to access files in
		# ~www-content, but they won’t necessarily need to have access
		# to everything that’s in there.
		homeMode = "710";

		openssh.authorizedKeys.keys = (import values/ssh-authorized-keys.nix);
	};
}
