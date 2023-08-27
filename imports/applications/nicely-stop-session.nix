# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2023)
with import <nixpkgs> { };

writeShellApplication {
	name = "nicely-stop-session";
	runtimeInputs = [
		coreutils  # for sleep
		qt6.qttools  # for qdbus
		systemd  # for systemctl
	];
	text = ''
		readonly es_wrong_number_of_arguments=1
		readonly es_invalid_shutdown_type=2

		function echo_err
		{
			echo "$@" >&2
		}

		function kde_shutdown
		{
			# Thanks, Gilles 'SO- stop being evil'
			# (<https://askubuntu.com/users/1059/gilles-so-stop-being-evil>)
			# and Raz Crimson
			# (<https://askubuntu.com/users/1106330/raz-crimson>)
			# for this answer: <https://askubuntu.com/a/1876/565319>

			qdbus org.kde.Shutdown /Shutdown "$@"
		}


		if [ "$#" -ne 1 ]; then
			echo_err "USAGE: nicely-stop-session <shutdown | reboot>"
			exit "$es_wrong_number_of_arguments"
		fi

		if [ "$1" = shutdown ]
		then
			kde_shutdown_type="Shutdown"
			systemctl_shutdown_type="poweroff"
		elif [ "$1" = reboot ]
		then
			kde_shutdown_type="Reboot"
			systemctl_shutdown_type="reboot"
		else
			# shellcheck disable=SC1111
			echo_err -E \
				"ERROR: Unknown shutdown type" \
				"“$1”. Shutdown type should either be" \
				"“shutdown” or “reboot”."
			exit "$es_invalid_shutdown_type"
		fi
		readonly kde_shutdown_type systemctl_shutdown_type

		# We wait 30 seconds here to give other scripts a chance
		# to close out of the current terminal.
		sleep 30s
		kde_shutdown logoutAnd"$kde_shutdown_type" || \
			systemctl "$systemctl_shutdown_type"
	'';
}