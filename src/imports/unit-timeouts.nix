# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
{ config, pkgs, ... }:
let
	timeout = 1800;
in {
	# In general, I’d rather have units that take a long time to start and
	# stop than have units that sometimes timeout. This is especially true
	# on Jason-Laptop-Linux, a computer that is rather slow.
	systemd.extraConfig = ''
		DefaultTimeoutStartSec=${toString timeout}
		DefaultTimeoutStopSec=${toString timeout}
	'';
	systemd.user.extraConfig = config.systemd.extraConfig;
	# Unfortunately, home-manager hard codes this. See
	# <https://github.com/nix-community/home-manager/blob/586ac1fd58d2de10b926ce3d544b3179891e58cb/nixos/default.nix#L49>
	# and
	# <https://github.com/nix-community/home-manager/issues/3247>.
	systemd.services.home-manager-jayman.serviceConfig.TimeoutStartSec = pkgs.lib.mkForce timeout;
}
