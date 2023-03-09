# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2023)
with import <nixpkgs> { };

writeShellApplication {
	name = "jasons-self-test-script";
	runtimeInputs = [
		iputils
		knot-dns
	];
	text = ''
		# writeShellApplication enables this by default. We need
		# to turn it off or else the script will exit when a
		# test fails. We need the script to reach the very end
		# or else the results won’t get printed.
		set +o errexit

		# This is needed for the while look in
		# disk_space_too_low to modify the exit_status variable
		# sucessfully.
		shopt -s lastpipe

		### Helper functions: ###
		# This lets you echo the value of a variable, even if
		# the variable looks like a commandline flag (for
		# example: the "$var" might be “-E”).
		function echo_raw
		{
			printf '%s\n' "$*"
		}

		function record_mismatch
		{
			if [ "$#" -ne 4 ]
			then
				echo_raw \
					"The record_mismatch funtion" \
					"was called with $# " \
					"arguments. It should only" \
					"ever be called with 4" \
					"arguments."
			fi
			local -r domain="$1"
			shift
			local -r type="$1"
			shift
			local -r expected="$1"
			shift
			# If record_mismatch is called with too many
			# arguments, act like the extra arguments were
			# packed into the last argument.
			local -r actual="$*"

			# shellcheck disable=SC1111
			echo_raw \
				"$domain’s $type record" \
				"should be “$expected”, but" \
				"it’s actually “$actual”."
		}

		### Test functions: ###
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

		function any_failed_systemd_units
		{
			local -r none='0 loaded units listed.'

			local unit_list
			unit_list="$(systemctl list-units --failed 2>&1)"
			local -r unit_list_error_code="$?"
			readonly unit_list

			echo_raw "$unit_list"

			local exit_status=0
			if [ "$unit_list_error_code" -ne 0 ]
			then
				exit_status=1
				echo_raw \
					Listing units failed with exit \
					status "$unit_list_error_code"
			elif ! echo "$unit_list" | grep -F "$none"
			then
				exit_status=1
				echo At least one unit failed.
			fi
			return "$exit_status"
		}

		function disk_space_too_low
		{
			local exit_status=0
			local pcent target
			# The tail command gets rid of the table’s
			# headers.
			df --output=pcent,target |
				tail -n +2 |
				while read -r pcent target
				do
					# Turn pcent into a number with
					# no extra characters.
					pcent="$(
						echo_raw "$pcent" |
							tr -d " %"
					)"
					if [ "$pcent" -ge 85 ]
					then
						echo \
							"$target is" \
							"$pcent% full."
						exit_status=1
					fi
				done
			return "$exit_status"
		}

		function dns_ns
		{
			local -r domain=test.jasonyundt.email
			local -r expected_ns=nameserver.test.jasonyundt.email.
			local -r actual_ns="$(
				kdig NS "$domain" +short |
					tr -d $'\n'
			)"
			if [ "$expected_ns" = "$actual_ns" ]
			then
				return 0
			else
				record_mismatch \
					"$domain" \
					NS \
					"$expected_ns" \
					"$actual_ns"
				return 1
			fi
		}

		function dns_a_and_aaaa
		{
			local -r domain=nameserver.test.jasonyundt.email

			local -r ipv4_resolver=resolver4.opendns.com
			local ipv6_resolver
			ipv6_resolver=resolver1.ipv6-sandbox.opendns.com
			readonly ipv6_resolver

			# Thanks to Timo Tijhof
			# (<https://unix.stackexchange.com/users/37512/timo-tijhof>)
			# for this idea:
			# <https://unix.stackexchange.com/a/81699/316181>.
			local -r expected_a="$(
				kdig \
					-4 \
					"@$ipv4_resolver" \
					myip.opendns.com \
					+short
			)"
			local -r expected_aaaa="$(
				kdig \
					-6 \
					"@$ipv6_resolver" \
					AAAA \
					myip.opendns.com \
					+short
			)"

			local -r actual_a="$(
				kdig \
					A \
					"$domain" \
					+short
			)"
			local -r actual_aaaa="$(
				kdig \
					AAAA \
					"$domain" \
					+short
			)"
			local exit_status=0
			if [ "$expected_a" != "$actual_a" ]
			then
				record_mismatch \
					"$domain" \
					A \
					"$expected_a" \
					"$actual_a"
				exit_status=1
			fi
			if [ "$expected_aaaa" != "$actual_aaaa" ]
			then
				record_mismatch \
					"$domain" \
					AAAA \
					"$expected_aaaa" \
					"$actual_aaaa"
				exit_status=1
			fi

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

		test_names+=( "Failed systemd units" )
		test_logs+=( "$(any_failed_systemd_units 2>&1)" )
		test_exit_statuses+=( "$?" )

		test_names+=( "Disk space" )
		test_logs+=( "$(disk_space_too_low 2>&1)" )
		test_exit_statuses+=( "$?" )

		test_names+=( "NS record" )
		test_logs+=( "$(dns_ns 2>&1)" )
		test_exit_statuses+=( "$?" )

		test_names+=( "A and AAAA records" )
		test_logs+=( "$(dns_a_and_aaaa 2>&1)" )
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
