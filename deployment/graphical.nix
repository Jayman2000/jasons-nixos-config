# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
{ config, pkgs, ... }:
{
	imports = [
		./git.nix
		./neomutt.nix
		./syncthing.nix
		./tor-browser.nix
	];

	sound.enable = true;
	hardware.pulseaudio.enable = true;

	# Enable the X11 windowing system.
	services.xserver = {
		desktopManager.plasma5.enable = true;
		displayManager.sddm.enable = true;
		enable = true;
		layout = "us";
		libinput.enable = true;
	};

	environment.systemPackages = with pkgs; [
		aspell
		aspellDicts.en
		audacity
		noto-fonts
		noto-fonts-cjk
		noto-fonts-emoji
		noto-fonts-extra
		plasma5Packages.sonnet
		source-code-pro
	];

	fonts.fontconfig.defaultFonts = {
		emoji = [ "Noto Color Emoji" ];
		monospace = [ "Source Code Pro" ];
		sansSerif = [ "Noto Sans" ];
		serif = [ "Noto Serif" ];
	};

	home-manager.users.jayman = { pkgs, ... }: {
		home.packages = with pkgs; [
			ark
			godot
			kalendar
			keepassxc
			kgpg
			libreoffice-qt # Hopefully, the Qt version will look better with the Plasma desktop.
			thunderbird
			xclip
			yakuake
		];
		xdg.dataFile."fonts/CCSymbols.ttf".source = "/etc/nixos/deployment/CCSymbols.ttf";
		# This is required to make programs.bash.sessionVariables work in graphical sessions.
		xsession.enable = true;

		programs.firefox.enable = true;

		programs.ssh = {
			enable = true;
			extraConfig = "AddKeysToAgent yes";
		};
		services.gpg-agent = {
			enable = true;
			defaultCacheTtlSsh = 900;
			enableSshSupport = true;
			pinentryFlavor = "qt";
		};
	};
}
