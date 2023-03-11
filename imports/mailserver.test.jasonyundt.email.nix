# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2023)
{ config, pkgs, ... }:
{
	imports = [
		./home-manager/22.11.nix
		./common.nix
		./auto-upgrade.nix
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

	services.rdnssd.enable = true;
	# It can be tricky to get the DNS records for a mailserver
	# right. While it might be more robust to use an external DNS
	# provider, it would mean that I would have to find a way to
	# sync DNS records with that provider. There would be a lot of
	# configuration that wouldn’t be specified in any sort of Nix
	# expression.
	#
	# Ultimately, if I run my my own DNS server, then pretty much
	# everything that I need to run this mailserver can be declared
	# by this NixOS configuration.
	#
	# I chose Knot DNS based on this table [1]. It seems like Knot
	# DNS is the only authoritative DNS server that has at least
	# partial support for DNS over QUIC.
	#
	# [1]: <https://en.wikipedia.org/w/index.php?title=Comparison_of_DNS_server_software&oldid=1135374152#Feature_matrix>
	services.knot = {
		enable = true;
		# Referencing ./knot-dns/storage the way we do here will
		# add that path to the Nix store and replace any
		# references to ./knot-dns/storage with its Nix store
		# path. See
		# <https://discourse.nixos.org/t/what-are-nix-paths/14000/2>
		extraConfig = let
			configPath = ./knot-dns/knot.conf;
			rawConfig = builtins.readFile configPath;
			storagePath = ./knot-dns/storage;
		in builtins.replaceStrings
			[ "@storage@" ]
			[ "${storagePath}" ]
			rawConfig;
	};
	networking.firewall = let
		dnsPort = [ 53 ];
	in {
		allowedTCPPorts = dnsPort;
		allowedUDPPorts = dnsPort;
	};
}
