# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2023–2024)
{ pkgs, lib, ... }:
{
	nixpkgs.overlays = [
		(self: super: {
			pre-commit = let
				pkgCollections = import ../pkgCollections {
					inherit pkgs lib;
				};
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
	home-manager.users.jayman = { pkgs, ... }: {
		home.packages = [ pkgs.pre-commit ];
	};

	# Normally, I would just have pre-commit download its own copy of
	# NodeJS, but on NixOS that doesn’t work. I tried installed NodeJS for
	# jayman only, but that also didn’t work.
	environment.systemPackages = [ pkgs.nodejs ];
}
