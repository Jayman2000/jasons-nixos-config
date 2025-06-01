# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2024)
{ config, pkgs, lib, ... }:
{
	imports = [
		./build-gpg-web-site.nix
		./cc-symbols-font
		./games.nix
		./git-graphical.nix
		./legacy-locale.nix
		./neomutt.nix
		./syncthing.nix
		./tmpfs-and-swap.nix
		./unit-timeouts.nix
		./vm-host.nix
	];

	networking.networkmanager.enable = true;

	# Enable the X11 windowing system.
	services = {
		desktopManager.plasma6.enable = true;
		libinput.enable = true;
		displayManager.sddm = {
			enable = true;
			wayland.enable = true;
		};
		# This allows me to use IPv6 even though my ISP only gives me
		# IPv4 access. Source:
		# <https://old.reddit.com/r/ipv6/comments/jwdrx4/how_to_connect_to_ipv6_servers_from_ipv4only/gcr6q1r/?utm_source=reddit&utm_medium=web2x&context=3>.
		cloudflare-warp.enable = true;
	};

	environment.systemPackages = with pkgs; [
		aspell
		aspellDicts.en
		audacity
		noto-fonts
		noto-fonts-cjk-sans
		noto-fonts-emoji
		noto-fonts-extra
		kdePackages.sonnet
		kdePackages.kdenlive
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

	# Needed for Cloudflare WARP
	nixpkgs.config.allowUnfree = true;

	home-manager.users.jayman = { pkgs, ... }: {
		home.packages = let
			pkgCollections = import ../pkgCollections {
				inherit pkgs lib;
			};
		in [
			pkgs.ark
			pkgs.chars
			pkgs.filelight
			pkgs.gdb
			pkgs.gitlab-runner
			pkgs.kdialog  # Used by ecwolf
			pkgs.keepassxc
			pkgs.kgpg
			pkgs.libreoffice-qt # Hopefully, the Qt version will look better with the Plasma desktop.
			pkgs.merkuro
			pkgs.mpv
			pkgs.rsync
			pkgs.rustfmt
			pkgs.tdesktop
			pkgs.thunderbird
			pkgs.transmission_4-qt
			pkgs.xclip
			pkgs.yakuake

			# Browsers to test my site with.
			pkgs.librewolf
			pkgs.palemoon-bin
			pkgs.ungoogled-chromium

			pkgCollections.custom.cmark-html
		] ++ (if config.system.nixos.release == "23.05"
			then [ pkgs.godot ]
			else [ pkgs.godot3 ]);
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
		# Home Manager 24.05 removed the pinentryFlavor option and
		# replaced it with pinentryPackage. See
		# <https://github.com/nix-community/home-manager/pull/4895>.
		} // (if config.system.nixos.release == "23.11"
			then { pinentryFlavor = "qt"; }
			else { pinentryPackage = pkgs.pinentry-qt; }
		);

		programs.powerline-go.enable = true;
		home.shellAliases."randfd" = ''
			ls --zero | shuf -zn 1 | tr '\0' '\n'
		'';
	};
}
