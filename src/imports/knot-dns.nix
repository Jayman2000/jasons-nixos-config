# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2023)
{ pkgs, ... }:
{
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
		package = pkgs.knot-dns.overrideAttrs (previousAttrs: {
			version = "unstable-2023-08-21";
			src = let
				commit-ish = "46c11c339743064215d91bd364a0372bec5f8b11";
			in builtins.fetchTarball {
				url = "https://gitlab.nic.cz/knot/knot-dns/-/archive/${commit-ish}/knot-dns-${commit-ish}.tar.gz";
				sha256 = "0kah0qdvkv2v96gqwc4pj8nrzkz61d0q58gbj1myqx7l8cg8fixz";
			};
		});
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
