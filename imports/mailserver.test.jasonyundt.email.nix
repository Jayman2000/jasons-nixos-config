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

	# IPv6 was designed to give every computer on the Internet a
	# unique address (making NAT largely unnecessary). This would,
	# as a side effect, make it easier to track users since each
	# device would have a unique id.
	#
	# There’s various ways of periodically switching IPv6 addresses
	# to circumvent this problem. These extra config lines disable
	# those strategies. This machine’s IP addresses shouldn’t change
	# and should be public knowledge that’s accessible via DNS.
	#
	# Additionally, without these two options, the machine won’t be
	# able to access the Internet via IPv6 (it won’t use the IP
	# address that the VPS provider assigns it).
	networking.networkmanager.extraConfig = ''
		[connection]
		ipv6.addr-gen-mode=0
		ipv6.ip6-privacy=0
	'';

	users.users.jayman.openssh.authorizedKeys.keys = [
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGOkLREBd8ijpssLjYJABnPiAEK11+uTkalt1qO3UntX jayman@Jason-Desktop-Linux"
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAxhFrE4xzbbctfKmM731F3SEAilbltANP4J8WQhIAIb jayman@Jason-Lemur-Pro"
	];
}
