# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
{ config, pkgs, ... }:
let
	authorizedKeysInfo = (import values/ssh-authorized-keys.nix);
	rrsyncCommand = "${pkgs.rrsync}/bin/rrsync ${config.users.users.www-content.home}";

	# TODO: Do something about the weird indentation (see
	# <https://github.com/NixOS/nix/issues/3759>).
	rushCfg = ''
rush 2.0

rule test-rule
	match $command == "${rrsyncCommand}"
'';
	customRushPkg = pkgs.rush.overrideAttrs (previousAttrs: {
		configureFlags = [ "--sysconfdir=/etc" ];
		# Prevents “make install” from trying to copy something
		# to /etc/rush.rc.
		installFlags = [ "sysconfdir=$(out)/etc" ];
	});

	rushWrapperName = "rush";
	rushWrapperPath = "${config.security.wrapperDir}/${rushWrapperName}";
in {
	# Users who are allowed to run GNU Rush.
	users.groups.rush-users = { };

	environment.etc."rush.rc".text = rushCfg;
	security.wrappers."${rushWrapperName}" = {
		owner = "root";
		group = "rush-users";
		permissions = "u=x,g=x,o=";

		# TODO: Report bug with <man:configuration.nix(5)>’s description
		# of capabilities. They don’t mention that it has to be in the
		# “TEXTUAL REPRESENTATION” specified by <man:cap_from_text(3)>.

		# Without the CAP_SETGID capability, rush will give this error
		# whenever you try to run a command that you’re allowed to run:
		# “A system error occurred while attempting to execute command.”
		capabilities = "CAP_SETGID=pe";
		source = "${customRushPkg}/bin/rush";
	};
	environment.shells = [ "${rushWrapperPath}" ];

	# This workaround is for a bug with the rrsync package. The bug has been
	# fixed already (see <https://github.com/NixOS/nixpkgs/issues/181096>),
	# but the fix isn’t in a stable version of nixpkgs yet.
	environment.systemPackages = [ pkgs.python3 ];

	users.groups.www-content = { };
	users.users.www-content = {
		description = "This user’s home directory is where content served by Web servers is stored.";
		group = "www-content";
		extraGroups = [ "rush-users" ];
		isSystemUser = true;

		createHome = true;
		home = "/home/www-content";
		# Web servers are going to need to be able to access files in
		# ~www-content, but they won’t necessarily need to have access
		# to everything that’s in there.
		homeMode = "710";

		shell = "${rushWrapperPath}";
		openssh.authorizedKeys.keys = [
			''${authorizedKeysInfo.defaultOptions},command="${rrsyncCommand}" ${authorizedKeysInfo.mainKey}''
		];
	};
}
