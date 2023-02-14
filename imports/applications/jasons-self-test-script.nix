# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2023)
with import <nixpkgs> { };

writeShellApplication {
	name = "jasons-self-test-script";
	runtimeInputs = [ iputils ];
	text = ''
		# writeShellApplication enables this by default. We need
		# to turn it off or else the script will exit when a
		# test fails. We need the script to reach the very end
		# or else the results won’t get printed.
		set +o errexit

		# This lets you echo the value of a variable, even if
		# the variable looks like a commandline flag (for
		# example: the "$var" might be “-E”).
		function echo_raw
		{
			printf '%s\n' "$*"
		}

		function ping_test
		{
			# See <https://www.rfc-editor.org/rfc/rfc2606.html> and
			# <https://www.rfc-editor.org/errata/rfc2606>.
			# I’m assuming that if we can’t ping at least
			# one of these, then there’s something wrong
			# with our Internet connection.
			local -r test_domains="$(echo -n '
				example.com
				example.org
				example.net
				example.edu' | shuf)" && \
			local -r ip_version="$1" && \
			local exit_status=1 && \
			for test_domain in $test_domains
			do
				ping -"$ip_version" -c 16 "$test_domain"
				exit_status="$?"
				if [ "$exit_status" -eq 0 ]
				then
					return 0
				fi
			done
			return "$exit_status"
		}


		test_names=( )
		test_logs=( )
		test_exit_statuses=( )

		test_names+=( "IPv4 connection" )
		test_logs+=( "$(ping_test 4 2>&1)" )
		test_exit_statuses+=( "$?" )

		test_names+=( "IPv6 connection" )
		test_logs+=( "$(ping_test 6 2>&1)" )
		test_exit_statuses+=( "$?" )

		any_errors=0
		readonly total_tests="''\${#test_names[@]}"
		if \
			[ "$total_tests" -ne "''\${#test_logs[@]}" ] ||
			[ "$total_tests" -ne "''\${#test_exit_statuses[@]}" ]
		then
			# shellcheck disable=SC1110
			echo \
				ERROR: the test_names, test_logs and \
				test_exit_statuses arrays aren’t all \
				same size. This should never happen, \
				even when tests fail. 1>&2
			any_errors=1
		fi

		for ((i = 0; i < "$total_tests"; i++))
		do
			if [ "''\${test_exit_statuses[$i]}" -ne 0 ]
			then
				any_errors=1
				echo_raw \
					============== \
					"''\${test_names[$i]}" \
					test failed \
					==============
				echo Log:
				echo_raw "''\${test_logs[$i]}"
				echo_raw \
					Exit status: \
					"''\${test_exit_statuses[$i]}"
			fi
		done
		if [ "$any_errors" -eq 0 ]
		then
			echo "All tests suceeded."
		fi
		exit "$any_errors"
	'';
}
