# SPDX-FileNotice: 🅭🄍1.0 Unless otherwise noted, everything in this file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-License-Identifier: GPL-2.0-or-later
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
# SPDX-FileContributor: Jacob Adams <tookmund@gmail.com>
{ config, pkgs, ... }:
{
	boot.tmpOnTmpfs = true;
	# This is probably way more than I need, but I have a lot of swap, so
	# it’s probably fine.
	boot.tmpOnTmpfsSize = "290%";

	# This next section was adapted from Swapspace’s swapspace.service. See:
	# <https://github.com/Tookmund/Swapspace/blob/62c25dbc3f4741f23c99b6c9310c17d63391ad10/swapspace.service>
	# BEGIN GPL-2.0-or-later LICENSED SECTION
	systemd.services.swapspace = let
		dependencies = [ "local-fs.target" "swap.target" ];
		swapFileDirBase = if config.networking.hostName == "Jason-Desktop-Linux" then "/hdd/home" else "";
		swapFileDir = "${swapFileDirBase}/var/lib/swapspace";
		swapspacePkg = (import ./applications/swapspace.nix);
	in {
		description = "Swapspace, a dynamic swap space manager";
		documentation = [ "man:swapspace(8)" ];
		after = dependencies;
		requires = dependencies;

		path = [
			pkgs.coreutils  # for mkdir and chmod
			pkgs.util-linux  # for mkswap (swapspace runs it)
			swapspacePkg
		];
		# Technically, I could use mkdir’s -m flag instead of chmod,
		# but then (I’m assuming) /var and /var/lib would have their
		# permissions set to 700 if they didn’t already exist.
		script = ''
			[ -d '${swapFileDir}' ] && mkdir -p '${swapFileDir}' && chmod 700 '${swapFileDir}'
			swapspace --swappath='${swapFileDir}'
		'';
		serviceConfig = {
			Restart = "always";
			RestartSec = 30;
		};
		wantedBy = [ "multi-user.target" ];
	};
	# END GPL-2.0-or-later LICENSED SECTION
}
