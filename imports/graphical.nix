# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2023)
{ config, pkgs, ... }:
{
	imports = [
		./games.nix
		./git-graphical.nix
		./neomutt.nix
		./syncthing.nix
		./tor-browser.nix
		./tmpfs-and-swap.nix
		./unit-timeouts.nix
		./vm-host.nix
	];

	sound.enable = true;
	hardware.pulseaudio.enable = true;
	networking.networkmanager.enable = true;

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

	# Needed for local GitLab Runner
	users.users.jayman.extraGroups = [ "docker" ];
	virtualisation.docker.enable = true;

	home-manager.users.jayman = { pkgs, ... }: {
		home.packages = with pkgs; [
			ark
			chars
			filelight
			gitlab-runner
			godot
			kalendar
			kdialog  # Used by ecwolf
			keepassxc
			kgpg
			libreoffice-qt # Hopefully, the Qt version will look better with the Plasma desktop.
			mpv
			rsync
			rustfmt
			tdesktop
			thunderbird
			transmission-qt
			xclip
			yakuake

			# Browsers to test my site with.
			librewolf
			palemoon
			ungoogled-chromium

			(import applications/cmark-html.nix)
		];
		xdg.dataFile."fonts/CCSymbols.ttf".source = "/etc/nixos/imports/CCSymbols.ttf";
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

		programs.powerline-go.enable = true;
		home.shellAliases."randfd" = ''
			ls --zero | shuf -zn 1 | tr '\\0' '\\n'
		'';
	};
}
