# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2024)
{ pkgs, custom }:

pkgs.resholve.writeScriptBin "remote-deploy" {
	execer = [
		"cannot:${custom.deploy-jasons-nixos-config}/bin/deploy-jasons-nixos-config"
		# TODO: Revisit this one once
		# <https://github.com/abathur/resholve/issues/90> is resolved.
		"cannot:${pkgs.openssh}/bin/ssh"
	];
	inputs = [
		custom.deploy-jasons-nixos-config
		pkgs.openssh
	];
	interpreter = "${pkgs.bash}/bin/bash";
} ''
	set -e

	if [ ! -v JNC_REMOTE_DEPLOY_ADDRESS ]
	then
		echo \
			ERROR: The JNC_REMOTE_DEPLOY_ADDRESS \
			environment variable wasn’t set. Set it to the \
			address of the system that you want to deploy \
			on. \
		1>&2
		exit 1
	fi
	declare -xr JNC_NIXOS_REBUILD_AS_ROOT=0
	# This is required for “--use-remote-sudo” to work. See
	# <https://discourse.nixos.org/t/which-commands-are-required-for-remote-switch/17936/2?u=jasonyundt>.
	declare -xr NIX_SSHOPTS="-t"
	readonly destination="jayman@$JNC_REMOTE_DEPLOY_ADDRESS"
	deploy-jasons-nixos-config \
		boot \
		--upgrade \
		--target-host "$destination" \
		--use-remote-sudo
	ssh $NIX_SSHOPTS "$destination" nicely-stop-session reboot
''
