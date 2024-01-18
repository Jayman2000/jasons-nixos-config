# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2023)
{ config, pkgs, ... }:
{
	imports = [ ./msmtp.nix ];
	systemd.services.jasons-self-test-script = let
		dependencies = [ "network-online.target" ];
	in {
		enable = true;
		wants = dependencies;
		after = dependencies;
		description = "Jason’s Self-test Script";

		path = [
			# There’s a comment in msmtp.nix that explains why
			# inetutils is needed.
			pkgs.inetutils
		];
		startAt = "hourly";
		script = let
			fqdn = config.networking.fqdn;
			jasonsSelfTestScript = (import ./applications/jasons-self-test-script.nix { inherit pkgs; });
			subject = "Self-tests failed on ${fqdn}";

			implementation = pkgs.resholve.writeScript "jasons-self-test-script-service-implementation" {
				execer = [
					# TODO: This won’t be necessary
					# once this PR is completed:
					# <https://github.com/abathur/binlore/pull/11>
					"cannot:${pkgs.perlPackages.mimeConstruct}/bin/mime-construct"
					# TODO: This won’t be necessary
					# once this PR is merged:
					# <https://github.com/abathur/resholve/pull/103>
					"cannot:${pkgs.msmtp}/bin/msmtpq"
				];
				inputs = [
					jasonsSelfTestScript
					pkgs.msmtp
					pkgs.perlPackages.mimeConstruct
				];
				interpreter = "${pkgs.bash}/bin/bash";
			} ''
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
		in "${implementation}";
	};
}
