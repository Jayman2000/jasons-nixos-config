# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2023)
{ config, pkgs, ... }:
{
	imports = [
		./git-common.nix
		./neovim.nix
		./sudo.nix
	];

	i18n.defaultLocale = "en_US.UTF-8";
	console = {
		font = "Lat2-Terminus16";
		keyMap = "us";
	};

	nix.gc = {
		dates = "weekly";
		options = "--delete-older-than 30d";
		persistent = true;
		randomizedDelaySec = "45min";
	};

	# This allows users to run “systemctl poweroff” and
	# “systemctl reboot” without sudo [1].
	#
	# [1]: <https://wiki.archlinux.org/title/Systemd#Power_management>
	security.polkit.enable = true;

	environment.defaultPackages = [ ];
	environment.systemPackages = [ pkgs.htop ];
	home-manager.useGlobalPkgs = true;

	users.users.jayman = {
		description = "Jason Yundt";
		isNormalUser = true;
	};
	home-manager.users.jayman = { pkgs, ... }: {
		home.stateVersion = config.system.stateVersion;
		home.packages = with pkgs; [
			file
		];
		programs.bash = {
			# I think that this is necesary. Without it, I don’t think that the programs in home.packages would end up on my PATH.
			enable = true;

			initExtra = ''
				function mkcd {
					mkdir -p "$*"
					cd "$*"
				}
			'';
			sessionVariables = { EDITOR = "nvim"; };
		};
	};
}
