# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2023–2024)
{ config, pkgs, lib, ... }:
let
	pkgCollections = import ../pkgCollections { inherit pkgs lib; };
in {
	imports = [ ./git-common.nix ];

	nixpkgs.overlays = [
		(self: super: {
			pre-commit = let
				# This PR fixes a bug with pre-commit:
				# <https://github.com/NixOS/nixpkgs/pull/267499>.
				# It’s been merged into Nixpkgs’s master branch,
				# but hasn’t been backported to NixOS 23.11 yet.
				# That’s why we’re using nixpkgs-unstable here.
				unstablePkgs = pkgCollections.nixpkgs-unstable;
			in unstablePkgs.pre-commit.override {
				# Some of the pre-commit hooks that I use [1]
				# require Python 3.12. We need to make
				# pre-commit use Python 3.12, or else those
				# hooks won’t work.
				#
				# [1]: <https://github.com/Jayman2000/jasons-pre-commit-hooks/>
				python3Packages = unstablePkgs.python312Packages;
			};
		})
	];
	# Normally, I would just have pre-commit download its own copy of NodeJS, but
	# on NixOS that doesn’t work. I tried installed NodeJS for jayman only, but
	# that also didn’t work.
	environment.systemPackages = [ pkgs.nodejs ];
	home-manager.users.jayman = { pkgs, ... }: {
		# Adapted from
		# <https://nix-community.github.io/home-manager/index.html#_how_do_i_install_packages_from_nixpkgs_unstable>.
		home.packages = [
			pkgs.cargo # Used for this repo’s pre-commit config
			pkgs.gcc # Used for this repo’s pre-commit config
			pkgs.go # Used for this repo’s pre-commit config
			pkgs.pre-commit
			pkgs.gh
			pkgs.python3Packages.grip
			pkgCollections.custom.git-bhc
			pkgCollections.custom.git-tb
		];
		programs.git = {
			# I’ll enable this once this option is available in a stable version of Home Manager.
			#diff-so-fancy.enable = true;
			# This will make sure that git-send-email is installed.
			package = pkgs.gitAndTools.gitFull;
			userEmail = "jason@jasonyundt.email";
			userName = "Jason Yundt";
			extraConfig = {
				init.defaultBranch = "main";
				sendemail = {
					smtpServer = "box.jasonyundt.email";
					smtpUser = "jason@jasonyundt.email";
					smtpEncryption = "tls";
					# See <https://www.mailgun.com/blog/email/which-smtp-port-understanding-ports-25-465-587/>.
					smtpServerPort = 587;
				};
			};
		};
		home.shellAliases."bhc" = "git bhc | tr -d '\n' | xclip -select clipboard";
	};
}
