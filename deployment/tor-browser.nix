# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
{
	# Normally, I would prefer using the OS’s package manager (Nix on NixOS) instead of Flatpak, but I’ll make an exception to use the Tor Browser Launcher.
	services.flatpak.enable = true;
	services.tor = {
		enable = true;
		client = {
			enable = true;
			dns.enable = true;
		};
	};
	security.sudo.extraRules = [
		{
			users = [ "jayman" ];
			commands = [
				{
					command = "/etc/nixos/deployment/add-flathub.sh";
					options = [ "NOPASSWD" ];
				}
			];
		}
	];
	home-manager.users.jayman = { pkgs, ... }: {
		# This isn’t a very good way of having declarative Flatpaks, but it’s what works at the moment.
		xsession.initExtra = ''
			sudo /etc/nixos/deployment/add-flathub.sh
			flatpak install flathub com.github.micahflee.torbrowser-launcher -y
		'';
	};
}
