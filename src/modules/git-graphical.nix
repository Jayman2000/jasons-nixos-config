# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2023–2024)
{ config, pkgs, lib, ... }:
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
			pre-commit = pr267499Pkgs.pre-commit;
		})
	];
	# Normally, I would just have pre-commit download its own copy of NodeJS, but
	# on NixOS that doesn’t work. I tried installed NodeJS for jayman only, but
	# that also didn’t work.
	environment.systemPackages = [ pkgs.nodejs ];
	home-manager.users.jayman = { pkgs, ... }: {
		# Adapted from
		# <https://nix-community.github.io/home-manager/index.html#_how_do_i_install_packages_from_nixpkgs_unstable>.
		home.packages = let
			customPkgs = import ../pkgs { inherit pkgs lib; };
		in [
			pkgs.cargo # Used for this repo’s pre-commit config
			pkgs.gcc # Used for this repo’s pre-commit config
			pkgs.go # Used for this repo’s pre-commit config
			pkgs.pre-commit
			pkgs.gh
			pkgs.python3Packages.grip
			customPkgs.git-bhc
			customPkgs.git-tb
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
