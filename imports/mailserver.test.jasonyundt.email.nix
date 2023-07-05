# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2023)
{ config, pkgs, ... }:
{
	imports = [
		./home-manager/23.05.nix
		./common.nix
		./auto-upgrade.nix
		./knot-dns.nix
		./tmpfs-and-swap.nix
		./self-test.nix
	];

	# The server itself is in Paris, but I’ll be using it from
	# computers in America, so no timezone quite makes sense here.
	time.timeZone = "Etc/UTC";

	# The goal here is to make networking.fqdn accurate.
	networking.hostName = "mailserver";
	networking.domain = "test.jasonyundt.email";

	users.users.jayman.openssh.authorizedKeys.keys = [
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGOkLREBd8ijpssLjYJABnPiAEK11+uTkalt1qO3UntX jayman@Jason-Desktop-Linux"
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAxhFrE4xzbbctfKmM731F3SEAilbltANP4J8WQhIAIb jayman@Jason-Lemur-Pro"
	];

	# The LAN for Gandicloud VPS doesn’t seem to advertise IPv6 DNS
	# recursive resolver addresses. I’m also adding some IPv4
	# addresses here as a back up.
	networking.nameservers = let
		recursiveResolvers = import ./recursive-resolvers.nix;
	in builtins.concatLists [
		recursiveResolvers.expectedARecords
		recursiveResolvers.expectedAAAARecords
	];
}
