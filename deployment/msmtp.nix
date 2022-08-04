# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
{ config, pkgs, ... }:
{
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
	systemd.services.flush-msmtpq-queue = let
		dependencies = [ "network-online.target" ];
	in {
		wants = dependencies;
		after = dependencies;
		description = "try to send any emails that are stuck in msmtpq’s queue";

		path = with pkgs; [
			msmtp
			# netcat-gnu is a dependency of msmtp [1], but, for
			# whatever reason, msmtpq is failing to find the netcat
			# executable when I run it from a systemd service.
			#
			# [1]: <https://github.com/NixOS/nixpkgs/blob/36b9f3d40b822eadfc5c81c9762404d2d3d8374b/pkgs/applications/networking/msmtp/default.nix#L2>
			netcat-gnu
			# msmtpq uses which to test whether or not the nc
			# command is available. Unfortunately, msmtpq makes an
			# incorrect assumption. It tells you that nc isn’t
			# available if running “which nc” fails [1]. “which nc”
			# will fail if nc isn’t available, but “which nc” will
			# also fail if which isn’t available.
			#
			# [1]: <https://git.marlam.de/gitweb/?p=msmtp.git;a=blob;f=scripts/msmtpq/msmtpq;h=4b074dea78e2052a6b7e34a27b2dab5d24e3fbb4;hb=0f8e1c49f7b915c0a70d204e2fd5ffb7979f11b6#l211>
			which
		];
		script = ''
			msmtpq --q-mgmt -r
		'';
	};
}
