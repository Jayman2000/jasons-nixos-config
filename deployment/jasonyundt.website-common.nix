# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
{ config, pkgs, ... }:
{
	imports = [ ./efi.nix ];

	# TODO: Update this interface’s name.
	#networking.interfaces.enp8s0.useDHCP = true;
	time.timeZone = "America/New_York";

	# The goal here is to make networking.fqdn accurate.
	networking.hostName = "jasonyundt";
	programs.msmtp = {
		enable = true;
		accounts.default = {
			domain = config.networking.fqdn;
			auth = true;
			from = "${config.networking.fqdn}+%U@jasonyundt.email";
			syslog = true;

			host = "box.jasonyundt.email";
			# 587 is the recommended port for SMTP over TLS [1], and it happens to be
			# one of the ports that my mail server supports for SMTP.
			#
			# Mail-in-a-box is configured such that connections to port 587 must
			# start unencrypted and be upgraded using STARTTLS. Luckily, it also
			# requires that TLS be active if you want to do anything [2].
			# [1]: <https://www.mailgun.com/blog/email/which-smtp-port-understanding-ports-25-465-587/>
			# [2]: <https://github.com/mail-in-a-box/mailinabox/blob/main/security.md#services-behind-tls>
			port = 587;
			tls = true;
			tls_starttls = true;

			user = "${config.networking.fqdn}@jasonyundt.email";
			passwordeval = "cat ~root/mail-password";
		};
	};
	systemd.services.auto-update = {
		enable = true;
		wants = ["network-online.target"];
		after = ["network-online.target"];
		description = "nixos-rebuild boot --upgrade";

		# I don’t know if config.nix.envVars is needed here, but NixOS’s built in automatic updating service [1] includes it [2].
		# [1]: <https://nixos.org/manual/nixos/stable/index.html#sec-upgrading-automatic>
		# [2]: <https://github.com/NixOS/nixpkgs/blob/57cd07f3a9d27d1a63918fe21add060ecde4a29f/nixos/modules/tasks/auto-upgrade.nix#L174>
		environment = config.nix.envVars // {
			# This is needed so that nixos-rebuild can find nixpkgs.
			inherit (config.environment.sessionVariables) NIX_PATH;
		};
		# This makes nix-channel available to the script. nix-channel is needed by nixos-rebuild boot --upgrade.
		path = [ config.nix.package.out ];
		script = let
			# This is what NixOS’s built in automatic updating service [1] does [2]. I don’t know why it does it like that.
			# [1]: <https://nixos.org/manual/nixos/stable/index.html#sec-upgrading-automatic>
			# [2]: <https://github.com/NixOS/nixpkgs/blob/57cd07f3a9d27d1a63918fe21add060ecde4a29f/nixos/modules/tasks/auto-upgrade.nix#L190>
			nixos-rebuild = "${config.system.build.nixos-rebuild}/bin/nixos-rebuild";
		in "${nixos-rebuild} boot --upgrade";
	};
}
