# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2024)
#
# This file is used to test jasonyundt.website in a local VM. That’s why its host name ends in .home.arpa (see <https://www.ctrl.blog/entry/homenet-domain-name.html>).
{ config, pkgs, ... }:
{
	imports = [
		./jasonyundt.website-common.nix
		./disko/common.nix
		./disko/jasonyundt.website.home.arpa.nix
		./serial-console.nix
	];

	# The goal here is to make networking.fqdn accurate.
	networking.domain = "website.home.arpa";
}
