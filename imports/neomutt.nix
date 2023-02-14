# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
let
	# Neonwolf is a color scheme for NeoMutt.
	neonwolf-repo = builtins.fetchGit {
		url = https://github.com/h3xx/mutt-colors-neonwolf.git;
		ref = "main";
		rev = "165a9bc5c190fb422d4814d3740279cbd342dc88";
	};
in
{
	home-manager.users.jayman = { pkgs, ... }: {
		home.packages = with pkgs; [
			neomutt
		];
		# Home Manager does have options specifically for Neomutt and email in general, but I find them to be frustrating.
		xdg.configFile."neomutt/neomuttrc".text =
			let
				address_local_part = "jason";
				address_domain = "jasonyundt.email";
				# NOTE: address can’t contain an ASCII apostrophe. It would break the pass_command.
				address = "${address_local_part}@${address_domain}";
				address_percent_encoded = "${address_local_part}%40${address_domain}";
				mail_server_domain = "box.${address_domain}";
				pass_command = "`kwallet-query -f Passwords -r '${address}' default`";
			in
			''
				set real_name = "Jason Yundt"
				set from = "${address}"

				# Settings from Mail-in-a-box’s instructions and
				# <https://neomutt.org/test-doc/bestpractice/nativimap>
				set spoolfile="imaps://${mail_server_domain}:993/"
				set imap_user = "${address}"
				set imap_pass = "${pass_command}"

				# 587 is the recommended port for SMTP over TLS [1], and it happens to be
				# one of the ports that my mail server supports for SMTP. That’s why I
				# specify the port at the end of the URL.
				#
				# Mail-in-a-box is configured such that connections to port 587 must
				# start unencrypted and be upgraded using STARTTLS. Luckily, it also
				# requires that TLS be active if you want to do anything [2].
				# Additionally, NeoMutt will require TLS when ssl_force_tls is on [3].
				# That’s why I’m using the smtp:// scheme instead of the smtps://
				# scheme.
				# [1]: <https://www.mailgun.com/blog/email/which-smtp-port-understanding-ports-25-465-587/>
				# [2]: <https://github.com/mail-in-a-box/mailinabox/blob/main/security.md#services-behind-tls>
				# [3]: neomuttrc(5)
				set smtp_url = "smtp://${address_percent_encoded}@${mail_server_domain}:587"
				set ssl_force_tls = yes
				set smtp_pass = "${pass_command}"

				set folder = $spoolfile
				set postponed = "+Drafts"
				set record = "+Sent"
				set trash = "+Trash"
				mailboxes $spoolfile $postponed $record $trash +todo-open +todo-closed

				set sidebar_visible
				bind index,pager B sidebar-toggle-visible
				set sidebar_divider_char = '│'
				set sidebar_format = "%B%?F? [%F]?%* %?N?%N/?%S"
				set mail_check_stats
				bind index,pager \CP sidebar-prev
				# Ctrl-P – Previous Mailbox
				bind index,pager \CN sidebar-next
				# Ctrl-N – Next Mailbox
				bind index,pager \CO sidebar-open
				# Ctrl-O – Open Highlighted Mailbox

				macro index,pager <f2> "<save-message>+todo-open<enter>y" "Move to todo-open"
				macro index,pager <f10> "<save-message>+todo-closed<enter>y" "Move to todo-closed"
				macro index,pager <f5> "<mail>self<enter>[" "Start creating To Do Item"

				source ${neonwolf-repo}/mutt-colors-neonwolf-256.muttrc

				alias self Jason Yundt <jason@jasonyundt.email>
			'';
	};
}
