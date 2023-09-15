# SPDX-FileNotice: 🅭🄍1.0 Unless otherwise noted, everything in this file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-License-Identifier: GPL-2.0-or-later
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2023)
# SPDX-FileContributor: Jacob Adams <tookmund@gmail.com>
{ config, pkgs, ... }:
let
	# I which I could just say “all tmpfses will report that they’re full
	# only if 90% of how ever much virtual memory we currently have is in
	# use.”
	#
	# I’m using a much lower number on mailserver.test.jasonyundt.email
	# because that machine only has 25G of disk space.
	normalTmpfsSize = if config.networking.hostName == "mailserver" then "10G" else "40G";
	ramConstrainedTmpfsSize = "45%";
in {
	boot.devShmSize = normalTmpfsSize;
	services.logind.extraConfig = ''
		RuntimeDirectorySize=${normalTmpfsSize}
	'';
	# If the /run tmpfs ends up being larger than the machine’s physical
	# RAM, then you won’t be able to shutdown cleanly. The systemd
	# executable is stored in /run, so /run can’t be unmounted until very
	# late in the boot process. Unfortunately, “very late in the boot
	# process” ends up meaning “after all swap partitions and files have
	# been deactivated”. So the system can’t unmount /run until after all of
	# the swap has been deactivated, and all of the swap can’t be
	# deactivated until after /run is unmounted.
	boot.runSize = ramConstrainedTmpfsSize;
	# The swap partition’s block device is located in /dev. If the swap
	# partition just so happens to be the only swap that the system
	# currently has available and /dev is large enough that it needs that
	# swap, then you won’t be able to unmount /dev. /dev will require the
	# swap partition and the swap partition will require /dev. In a
	# situation like that, you won’t be able to shut down.
	boot.devSize = ramConstrainedTmpfsSize;

	# My main concern is running out of virtual memory or hitting the size
	# limit of a tmpfs. I’ll happily slow the system down a bit in order to
	# avoid both of those things.
	boot.tmpOnTmpfs = false;
	# My expectation is that /tmp will be cleared when the system shuts
	# down. It wouldn’t be a good idea, but I could see a program storing
	# sensitive data in /tmp. The logic would go like this: “If the program
	# shuts down successfully, then it will delete the file. If the program
	# doesn’t shut down successfully, then it will get deleted when the
	# system shuts down.”
	boot.cleanTmpDir = true;

	# This next section was adapted from Swapspace’s swapspace.service. See:
	# <https://github.com/Tookmund/Swapspace/blob/62c25dbc3f4741f23c99b6c9310c17d63391ad10/swapspace.service>
	# BEGIN GPL-2.0-or-later LICENSED SECTION
	systemd.services.swapspace = let
		dependencies = [ "local-fs.target" "swap.target" ];
		swapFileDirBase = if config.networking.hostName == "Jason-Desktop-Linux" then "/hdd/home" else "";
		swapFileDir = "${swapFileDirBase}/var/lib/swapspace";
		swapspacePkg = (import ./applications/swapspace.nix { inherit pkgs; });
	in {
		description = "Swapspace, a dynamic swap space manager";
		documentation = [ "man:swapspace(8)" ];
		after = dependencies;
		requires = dependencies;

		path = [
			pkgs.util-linux  # for mkswap (swapspace runs it)
		];
		# Technically, I could use mkdir’s -m flag instead of chmod,
		# but then (I’m assuming) /var and /var/lib would have their
		# permissions set to 700 if they didn’t already exist.
		script = let
			implementation = pkgs.resholve.writeScript "swapspace-service-implementation" {
				execer = [
					# TODO: Get this fixed upstream.
					# I don’t that I can start
					# getting this fixed upstream
					# until I contribute the
					# swapspace package to Nixpkgs.
					"cannot:${swapspacePkg}/bin/swapspace"
				];
				inputs = [
					pkgs.coreutils	# for mkdir and chmod
					swapspacePkg
				];
				interpreter = "${pkgs.bash}/bin/bash";
			} ''
				[ -d '${swapFileDir}' ] && mkdir -p '${swapFileDir}' && chmod 700 '${swapFileDir}'
				swapspace --swappath='${swapFileDir}'
			'';
		in "${implementation}";
		serviceConfig = {
			Restart = "always";
			RestartSec = 30;

			TimeoutSec = 1200;  # 20 minutes
		};
		wantedBy = [ "multi-user.target" ];
	};
	# END GPL-2.0-or-later LICENSED SECTION
	systemd.services.ensure-enough-vm-to-shutdown = let
		execStopScript = (import ./applications/ensure-enough-vm-to-shutdown.nix { inherit pkgs; });
	in {
		after = [ "swap.target" ];
		wantedBy = [ "swap.target" ];
		serviceConfig = {
			ExecStop = "${execStopScript}";
			RemainAfterExit = true;
		};

		unitConfig = {
			# I would rather keep DefaultDependencies on, but that
			# would create a dependency on sysinit.target. That
			# would be fine with me, but sysinit.target depends on
			# swap.target. In other words, it would create a
			# dependency cycle.
			DefaultDependencies = false;
			StopPropagatedFrom = "swap.target";
		};
		# Normally, these would be enabled by DefaultDependencies (see
		# systemd.services(5)).
		conflicts = [ "shutdown.target" ];
		before = [ "shutdown.target" ];
	};
}
