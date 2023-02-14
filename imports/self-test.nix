# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2023)
{ config, pkgs, ... }:
{
	imports = [ ./msmtp.nix ];
	systemd.services.jasons-self-test-script = let
		dependencies = [ "network-online.target" ];
		jasonsSelfTestScript = (import ./applications/jasons-self-test-script.nix);
	in {
		enable = true;
		wants = dependencies;
		after = dependencies;
		description = "Jason’s Self-test Script";

		path = [
			pkgs.msmtp
			pkgs.perlPackages.mimeConstruct
			# There’s a comment in msmtp.nix that explains why
			# inetutils is needed.
			pkgs.inetutils

			jasonsSelfTestScript
		];
		startAt = "hourly";
		script = let
			fqdn = config.networking.fqdn;
			subject = "Self-tests failed on ${fqdn}";
		in ''
			# Nix sets this by default. If
			# jasons-self-test-script fails, then we want
			# this script to keep running so that we can
			# mail the results.
			set +e

			# This lets you echo the value of a variable, even if
			# the variable looks like a commandline flag (for
			# example: the "$var" might be “-E”).
			function echo_raw
			{
				printf '%s\n' "$*"
			}

			log="$(jasons-self-test-script 2>&1)"
			readonly exit_status="$?"
			readonly log

			echo_raw "$log"

			if [ "$exit_status" -ne 0 ]
			then
				# There’s a comment in auto-upgrade.nix
				# that explains the mime-construct
				# command.
				echo_raw "$log" | mime-construct \
					--output \
					--subject "${subject}" \
					--to "jason@jasonyundt.email" \
					--type "text/plain; charset=UTF-8" \
					--file - | \
				msmtpq --read-recipients
			fi
			exit "$exit_status"
		'';
	};
}
