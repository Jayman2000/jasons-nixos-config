# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2023)
{ config, lib, pkgs, ... }:
{
	imports = [ ./msmtp.nix ];
	systemd.services.auto-update = let
		dependencies = [ "network-online.target" ];
	in {
		enable = true;
		wants = dependencies;
		after = dependencies;
		description = "nixos-rebuild boot --upgrade";

		# I don’t know if config.nix.envVars is needed here, but NixOS’s built in automatic updating service [1] includes it [2].
		# [1]: <https://nixos.org/manual/nixos/stable/index.html#sec-upgrading-automatic>
		# [2]: <https://github.com/NixOS/nixpkgs/blob/57cd07f3a9d27d1a63918fe21add060ecde4a29f/nixos/modules/tasks/auto-upgrade.nix#L174>
		environment = config.nix.envVars // {
			# This is needed so that nixos-rebuild can find nixpkgs.
			inherit (config.environment.sessionVariables) NIX_PATH;
		};
		path = [
			# This makes nix-channel available to the
			# script. nix-channel is needed by nixos-rebuild
			# boot --upgrade.
			config.nix.package.out
			# There’s a comment in msmtp.nix that explains why
			# pkgs.inetutils is needed.
			pkgs.inetutils
		];
		startAt = "daily";
		script = let
			pkgCollections = import ../pkgCollections {
				inherit pkgs lib;
			};
			bash-preamble = pkgCollections.custom.bash-preamble;
			fqdn = config.networking.fqdn;
			implementation = pkgs.resholve.writeScript "auto-upgrade-service-implementation" {
				execer = [
					# TODO: This won’t be necessary
					# once this PR is completed:
					# <https://github.com/abathur/binlore/pull/11>
					"cannot:${pkgs.perlPackages.mimeConstruct}/bin/mime-construct"
					# TODO: This won’t be necessary
					# once this PR is merged:
					# <https://github.com/abathur/resholve/pull/103>
					"cannot:${pkgs.msmtp}/bin/msmtpq"
					# TODO: This won’t be necessary
					# once this PR is merged:
					# <https://github.com/abathur/binlore/pull/14>
					"cannot:${config.system.build.nixos-rebuild}/bin/nixos-rebuild"
				];
				inputs = [
					bash-preamble.inputForResholve
					pkgs.msmtp
					pkgs.perlPackages.mimeConstruct
					# NixOS’s built-in automatic
					# updating service [1] doesn’t
					# just run whatever executable
					# the nixos-rebuild package [2]
					# provides. Instead, it runs the
					# one in
					# config.system.build.nixos-rebuild
					# [3]. I don’t know why it does
					# that, but I’ve decided to do
					# the same.
					#
					# [1]: <https://nixos.org/manual/nixos/stable/index.html#sec-upgrading-automatic>
					# [2]: <https://github.com/NixOS/nixpkgs/tree/841889913dfd06a70ffb39f603e29e46f45f0c1a/pkgs/os-specific/linux/nixos-rebuild>
					# [3]: <https://github.com/NixOS/nixpkgs/blob/57cd07f3a9d27d1a63918fe21add060ecde4a29f/nixos/modules/tasks/auto-upgrade.nix#L190>
					"${config.system.build.nixos-rebuild}/bin/"
				];
				interpreter = "${pkgs.bash}/bin/bash";
			} ''
				${bash-preamble.preambleForResholve}
				# For mime-constuct:
				#
				# --output prevents mime-construct from
				# trying to actually send the message
				# (if it did it would end up running
				# msmtp instead of msmtpq).
				#
				# If the charset isn’t specified, then
				# it defaults to “US-ASCII” [1]. While
				# it’s possible that nixos-rebuild will
				# only ever output ASCII characters, I’m
				# setting charset to UTF-8 just in case.
				# Also, I’m writting UTF-8 in all
				# uppercase because that’s how it’s
				# written in IANA’s charset list [2].
				#
				# [1]: <https://www.rfc-editor.org/rfc/rfc6657.html#section-4>
				# [2]: <https://www.iana.org/assignments/character-sets/character-sets.xhtml>

				nixos-rebuild boot --upgrade 2>&1 | \
				mime-construct \
					--output \
					--subject "auto-update run on ${fqdn}" \
					--to "jason@jasonyundt.email" \
					--type "text/plain; charset=UTF-8" \
					--file - | \
				msmtpq --read-recipients
			'';

		in "${implementation}";
	};
}
