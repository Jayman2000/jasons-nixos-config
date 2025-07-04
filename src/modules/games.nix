# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022, 2025)
{ config, pkgs, lib, ... }: let
	gameDataPath = (
		# TODO: It would be better if this said “if the config.services.syncthing.folders."Game Data" property exists”, but I don’t know how to say that.
		if config.networking.hostName == "Graphical-Test-VM"
		then
			"/var/empty"
		else
			config.services.syncthing.settings.folders."Game Data".path
	);
in {
	users.users.jayman.packages = (with pkgs; [
		_2048-in-terminal
		#abbaye-des-morts  # TODO: Figure out why this fails to build.
		#abuse	# TODO: Install on systems that already have unfree packages enabled.
		alephone  # TODO: Declaratively install game data.
		#alienarena  # TODO: Report upstream that this fails to build.
		#armagetronad  # TODO: Figure out why this doesn’t work.
		#assaultcube  # TODO: Install on systems that already have unfree packages enabled.
		atanks
		azimuth
		ballerburg
		blackshades
		blobby
		blobwars
		blockattack
		brutalmaze
		bsdgames
		btanks
		bugdom
		bzflag
		cdogs-sdl
		chromium-bsu
		curseofwar
		chocolateDoom
		cuyo
		ecwolf
		egoboo
		endgame-singularity
		endless-sky
		enigma
		extremetuxracer
		fish-fillets-ng
		fltrator
		freedink
		freedroid
		#frogatto  # TODO: Install on systems that already have unfree packages enabled.
		gnujump
		gotypist
		graphwar
		hedgewars
		kabeljau
		kdePackages.kmines
		lugaru
		mar1d
		mari0
		megaglest
		mindustry
		nanosaur
		nethack
		neverball
		ninvaders
		oh-my-git
		openarena
		opensupaplex
		openttd
		opentyrian
		#osu-lazer  # TODO: Install on systems that already have unfree packages enabled.
		otto-matic
		pacvim
		pinball
		powermanga
		prismlauncher
		redeclipse
		robotfindskitten
		rocksndiamonds
		rpg-cli
		rrootage
		#sauerbraten  # TODO: Restore this after this bug gets fixed: <https://github.com/NixOS/nixpkgs/issues/412963>.
		sdlpop
		#slade	# TODO: Reenable this one once this is fixed: <https://github.com/sirjuddington/SLADE/issues/1675>
		srb2
		srb2kart
		stuntrally
		superTuxKart
		superTux
		system-syzygy
		taisei
		tecnoballz
		teeworlds
		the-legend-of-edgar
		the-powder-toy
		# This one (and a few others below) fail to build on NixOS 23.05. See <https://github.com/NixOS/nixpkgs/issues/241341>.
		#titanion
		toppler
		# See the comment for titanion.
		#torus-trooper
		#tumiki-fighters
		unvanquished
		#urbanterror  # TODO: Install on systems that already have unfree packages enabled.
		vectoroids
		vimgolf
		vitetris
		#warsow  # TODO: Install on systems that already have unfree packages enabled.
		warzone2100
		wesnoth
		xmoto
		xonotic
	]) ++ (let
		pkgCollections = import ../pkgCollections {
			inherit pkgs lib;
		};
	in [
		(pkgCollections.custom.run-descent3.override {
			proprietaryGameDataDirectory = "${gameDataPath}/Descent/3/Fresh base directory";
		})
	]);
	home-manager.users.jayman = let
		doomDataPath = "${gameDataPath}/doom";
		soundFontPath = "${gameDataPath}/soundfonts/GM.sf2";
		wolf3DDataPath = "${gameDataPath}/Wolfenstien 3D";
	in
	{config, pkgs, ...}: {
		home.sessionVariables = {
			DOOMWADDIR = doomDataPath;

			SDL_FORCE_SOUNDFONTS = "1";
			SDL_SOUNDFONTS = soundFontPath;
		};
		xdg = {
			enable = true;
			# The mkOutOfStoreSymlnk part ensures that the
			# symlink gets created even if the target
			# doesn’t exist yet. The target won’t exist when
			# a fresh install is done (Syncthing won’t have
			# created the directory yet).
			dataFile.ecwolf.source = config.lib.file.mkOutOfStoreSymlink wolf3DDataPath;
		};
	};
}
