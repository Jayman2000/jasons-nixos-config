# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2023)
{ config, pkgs, ... }:
{
	imports = [ ./git-common.nix ];
	# Normally, I would just have pre-commit download its own copy of NodeJS, but
	# on NixOS that doesn’t work. I tried installed NodeJS for jayman only, but
	# that also didn’t work.
	environment.systemPackages = [ pkgs.nodejs ];
	home-manager.users.jayman = { pkgs, ... }: {
		# Adapted from
		# <https://nix-community.github.io/home-manager/index.html#_how_do_i_install_packages_from_nixpkgs_unstable>.
		home.packages = let
			unstablePkgs = (import ./nixpkgs-unstable.nix);
			# Thanks to strager
			# (<https://stackoverflow.com/users/39992/strager>)
			# for this idea:
			# <https://stackoverflow.com/a/71245733/7593853>
			pyOverrides = finalAttrs: previousAttrs: {
				# The version of python3Packages.cffi in
				# the 22.11 version of nixpkgs doesn’t
				# work with Python 3.11. See
				# <https://foss.heptapod.net/pypy/cffi/-/issues/551>.
				#
				# The only reason we want cffi to work
				# with Python 3.11 it’s an indirect
				# dependency of pre-commit. See below
				# for why we want to run pre-commit with
				# Python 3.11.
				cffi = unstablePkgs.python311Packages.cffi;
			};
			overlay = finalAttrs: previousAttrs: {
				python311 = previousAttrs.python311.override {
					packageOverrides = pyOverrides;
				};
			};
			pkgsToUse = (
				# See the comment in the pyOverrides
				# declaration.
				if config.system.nixos.release == "22.11" then
					import <nixpkgs> {
						overlays = [ overlay ];
					}
				else
					pkgs
			);
		in [
			pkgsToUse.cargo # Used for this repo’s pre-commit config
			pkgsToUse.gcc # Used for this repo’s pre-commit config
			pkgsToUse.go # Used for this repo’s pre-commit config

			# local-pre-commit-hooks/update-serial-numbers.py
			# is a script that requires Python 3.11. It’s
			# used by this repo’s update-serial-numbers
			# pre-commit hook. We need to make sure that
			# pre-commit uses Python 3.11 so that the mypy
			# hook uses Python 3.11. If we were to run the
			# mypy hook with Python 3.10, then the mypy hook
			# would fail to check that Python 3.11-only
			# script.
			(pkgsToUse.pre-commit.override {
				python3Packages = pkgsToUse.python311Packages;
			})

			(import applications/git-bhc.nix)
			(import applications/git-tb.nix)
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
