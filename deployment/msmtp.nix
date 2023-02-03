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
		startAt = "hourly";

		path = with pkgs; [
			msmtp
			# The msmtp package in Nixpkgs uses resholve [1] to
			# make sure that the commands used in the msmtpq script
			# are absolute paths [2]. As a result, we don’t have to
			# worry about whether or not the majority of commands
			# are on the PATH. Unfortunately, resholve doesn’t do
			# this for ping (among other commands) [3] [4]. As a
			# result, we have to make sure that ping is on the path
			# before running msmtpq or else msmtpq will try and fail
			# to run ping. When ping fails, msmtpq just assumes that
			# you don’t have access to the Internet and doesn’t even
			# try to run msmtp to acutally send the message [5] [6].
			#
			# [1]: <https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/misc/resholve/README.md>
			# [2]: <https://github.com/NixOS/nixpkgs/blob/9f8ce180e0a13d3148435417d8f264f5163ce9be/pkgs/applications/networking/msmtp/default.nix#L65>
			# [3]: <https://github.com/NixOS/nixpkgs/issues/195532#issuecomment-1324484168>
			# [4]: <https://github.com/abathur/resholve/issues/29>
			# [5]: <https://git.marlam.de/gitweb/?p=msmtp.git;a=blob;f=scripts/msmtpq/msmtpq;h=d8b4039338254ba9674fc95ffc252f674d965155;hb=8ee1b0e42f4a735c547caed35775cfe858e69d40#l203>
			# [6]: <https://git.marlam.de/gitweb/?p=msmtp.git;a=blob;f=scripts/msmtpq/msmtpq;h=d8b4039338254ba9674fc95ffc252f674d965155;hb=8ee1b0e42f4a735c547caed35775cfe858e69d40#l286>
			inetutils
		];
		script = ''
			msmtpq --q-mgmt -r
		'';
	};
}
