# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
{ config, pkgs, ... }:
let
	gitHomeDir = "/home/git";
in {
	services.openssh.enable = true;

	users.groups.git = { };
	users.users.git = {
		description = "Owner of Git repos. git-clone should use this user when cloning over SSH.";
		group = "git";
		isSystemUser = true;
		shell = "${pkgs.git}/bin/git-shell";

		# Git repos will be stored here. Also needed for the SSH
		# authorized keys file.
		createHome = true;
		home = gitHomeDir;
		# Any Web (HTTPS, FTP, IPFS, etc.) servers are going to need to
		# be able to read ~git/repos/, but they won’t need to have access
		# to anything else in git’s home folder. ~git/repos/ will have
		# its mode be 740 and users that are supposed to be able to
		# access ~git/repos/ will be added to the git group.
		homeMode = "710";

		openssh.authorizedKeys.keys = let
			restrictions = "no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty";
		in [
			"${restrictions} ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGOkLREBd8ijpssLjYJABnPiAEK11+uTkalt1qO3UntX jayman@Jason-Desktop-Linux"
		];

	};
	home-manager.users.git = { pkgs, ... }: {
		home.stateVersion = config.system.stateVersion;
		programs.git.enable = true;
		programs.git.extraConfig.core.hooksPath = "${(import applications/post-update.nix)}/bin";
	};

	# The git user has write permission for the repo folders. git-daemon
	# shouldn’t have that permission.
	users.users.git-daemon = {
		isSystemUser = true;
		group = "git";
	};
	services.gitDaemon = {
		enable = true;
		basePath = "${gitHomeDir}/repos";
		exportAll = true;
		group = "git";
		user = "git-daemon";
	};
	networking.firewall.allowedTCPPorts = [ config.services.gitDaemon.port ];
}
