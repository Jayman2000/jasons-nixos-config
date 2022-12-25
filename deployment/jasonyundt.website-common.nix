# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
{ config, pkgs, ... }:
{
	imports = [
		./home-manager/22.05.nix
		./common.nix
		./efi.nix
		./git-server.nix
		./msmtp.nix
	];

	# TODO: Update this interface’s name.
	#networking.interfaces.enp8s0.useDHCP = true;
	time.timeZone = "America/New_York";

	# The goal here is to make networking.fqdn accurate.
	networking.hostName = "jasonyundt";

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
		# This makes nix-channel available to the script. nix-channel is needed by nixos-rebuild boot --upgrade.
		path = [
			config.nix.package.out
			pkgs.msmtp
			pkgs.perlPackages.mimeConstruct

			# There’s a comment in msmtp.nix that explains why
			# “netcat-gnu” and “which” are needed.
			pkgs.netcat-gnu
			pkgs.which
		];
		startAt = "daily";
		script = let
			fqdn = config.networking.fqdn;
			# This is what NixOS’s built in automatic updating service [1] does [2]. I don’t know why it does it like that.
			# [1]: <https://nixos.org/manual/nixos/stable/index.html#sec-upgrading-automatic>
			# [2]: <https://github.com/NixOS/nixpkgs/blob/57cd07f3a9d27d1a63918fe21add060ecde4a29f/nixos/modules/tasks/auto-upgrade.nix#L190>
			nixos-rebuild = "${config.system.build.nixos-rebuild}/bin/nixos-rebuild";
		# For mime-constuct:
		#
		# --output prevents mime-construct from trying to actually send
		# the message (if it did it would end up running msmtp instead
		# of msmtpq).
		#
		# If the charset isn’t specified, then it defaults to
		# “US-ASCII” [1]. While it’s possible that nixos-rebuild will
		# only ever output ASCII characters, I’m setting charset to
		# UTF-8 just in case. Also, I’m writting UTF-8 in all uppercase
		# because that’s how it’s written in IANA’s charset list [2].
		#
		# [1]: <https://www.rfc-editor.org/rfc/rfc6657.html#section-4>
		# [2]: <https://www.iana.org/assignments/character-sets/character-sets.xhtml>
		in ''
			${nixos-rebuild} boot --upgrade 2>&1 | \
			mime-construct \
				--output \
				--subject "auto-update run on ${fqdn}" \
				--to "jason@jasonyundt.email" \
				--type "text/plain; charset=UTF-8" \
				--file - | \
			msmtpq --read-recipients
		'';
	};
}
