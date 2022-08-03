# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
{ config, pkgs, ... }:
{
	imports = [
		./efi.nix
		./msmtp.nix
	];

	# TODO: Update this interface’s name.
	#networking.interfaces.enp8s0.useDHCP = true;
	time.timeZone = "America/New_York";

	# The goal here is to make networking.fqdn accurate.
	networking.hostName = "jasonyundt";

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
