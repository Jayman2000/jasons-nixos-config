# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
{
	home-manager.users.jayman = { pkgs, ... }: {
		systemd.user.services.build-all-of-jnc = {
			Service.ExecStart = let
				build-all-of-jnc = (import ./applications/build-all-of-jnc.nix { inherit pkgs; });
			in "${build-all-of-jnc}/bin/build-all-of-jnc";
		};
		systemd.user.timers.build-all-of-jnc = {
			Install.WantedBy = [
				"graphical-session.target"
			];
			Timer = {
				OnActiveSec = "2 hours";
				RandomizedDelaySec = "30 minutes";
				Unit = "build-all-of-jnc.service";
			};
		};
	};
}
