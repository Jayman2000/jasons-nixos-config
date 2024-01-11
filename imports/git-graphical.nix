# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2023)
{ config, pkgs, ... }:
{
	imports = [ ./git-common.nix ];

	nixpkgs.overlays = let
		# This PR fixes a bug with pre-commit:
		# <https://github.com/NixOS/nixpkgs/pull/267499>.
		pr267499 = pkgs.fetchFromGitHub {
			owner = "NilsIrl";
			repo = "nixpkgs";
			rev = "69d78abdb885134bc339a89faa038dde99412f34";
			sha256 = "VSpebaHL3JFXg04Tp3T72nEv+5G0ECC/fR1M+Ni9bmA=";
		};
		pr267499Pkgs = import pr267499 {};
	in [
		(self: super: {
			# In another repo, I’m working on a program that
			# requires Python 3.12. That repo runs mypy [1]
			# as a pre-commit hook. By default, the nixpkgs
			# version of pre-commit doesn’t use Python 3.12
			# which results in mypy not being run using
			# Python 3.12. When mypy gets run with an older
			# version of Python, it won’t know about things
			# that have been added to the standard library
			# in Python 3.12.
			#
			# This override makes pre-commit use Python 3.12
			# which causes mypy to use Python 3.12 which
			# then causes mypy to actually understand my
			# code.
			#
			# [1]: <https://mypy-lang.org>
			pre-commit = pr267499Pkgs.pre-commit.override {
				python3Packages = pkgs.python312Packages;
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
			(import applications/git-bhc.nix { inherit pkgs; })
			(import applications/git-tb.nix { inherit pkgs; })
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
