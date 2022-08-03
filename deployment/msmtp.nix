# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
{ config, ... }:
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
}
