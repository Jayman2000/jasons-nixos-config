# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2023)
{ config, pkgs, ... }:
{
	imports = [
		./home-manager/22.11.nix
		./common.nix
		./auto-upgrade.nix
		./nixos-mailserver/22.11.nix
	];

	# The server itself is in Paris, but I’ll be using it from
	# computers in America, so no timezone quite makes sense here.
	time.timeZone = "Etc/UTC";

	# The goal here is to make networking.fqdn accurate.
	networking.hostName = "mail-test";
	networking.domain = "jasonyundt.website";

	users.users.jayman.openssh.authorizedKeys.keys = [
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGOkLREBd8ijpssLjYJABnPiAEK11+uTkalt1qO3UntX jayman@Jason-Desktop-Linux"
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAxhFrE4xzbbctfKmM731F3SEAilbltANP4J8WQhIAIb jayman@Jason-Lemur-Pro"
	];

	mailserver = {
		enable = true;
		fqdn = config.networking.fqdn;
		domains = [ config.networking.fqdn ];

		# Don’t allow IMAP with STARTTLS.
		enableImap = false;
		# Allow IMAP with implicit TLS.
		enableImapSsl = true;

		# Don’t allow SMTP with STARTTLS.
		enableSubmission = false;
		# Allow SMTP with implicit TLS.
		enableSubmissionSsl = true;

		hierarchySeparator = "/";

		# I’m using auto-upgrade.nix for automatic updating.
		rebootAfterKernelUpgrade.enable = false;

		loginAccounts = let
			userName = "jason";
			address = "${userName}@${config.networking.fqdn}";
		in {
			"${address}" = {
				catchAll = [ config.networking.fqdn ];
				hashedPasswordFile = "${config.users.users.root.home}/hashed-passwords/${userName}";
			};
		};

		certificateScheme = 3;
		# This was chosen based on this recommendation:
		# <https://crypto.stackexchange.com/a/72298>.
		dkimKeyBits = 2048;
	};
	# This is required in order to use mailserver.certificateScheme = 3.
	security.acme = {
		acceptTerms = true;
		email = "jason@jasonyundt.email";
	};
}
