# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2023)
with import <nixpkgs> { };

writeShellApplication {
	name = "jasons-self-test-script";
	runtimeInputs = [
		iputils
		knot-dns
	];
	text = let
		esa = lib.strings.escapeShellArg;
		rr = import ../recursive-resolvers.nix;
	in ''
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

		function check_dns_record
		{
			local exit_status=0

			if [ "$#" -lt 4 ]
			then
				echo_raw \
					"ERROR: The check_dns_record" \
					"funtion was called with $# " \
					"arguments. It should only" \
					"ever be called with 4" \
					"arguments, even when tests" \
					"fail."
				exit_status=1
			fi
			local -r domain="$1"
			shift
			local -r type="$1"
			shift
			local -r check_local="$1"
			shift
			local -r expectation="$*"

			local dns_servers=( "" )
			if [ "$check_local" -eq 1 ]
			then
				dns_servers+=( localhost )
			elif [ "$check_local" -ne 0 ]
			then
				# shellcheck disable=SC1111
				echo_raw \
					"ERROR: check_local is" \
					"“$check_local”. It should" \
					"only ever be 0 or 1. This" \
					"should never happen, even" \
					"when tests fail."
			fi
			readonly dns_servers

			local actual kdig_es
			for server in "''\${dns_servers[@]}"
			do
				for ipv in 4 6
				do
					for tp in udp tcp
					do
						# The arguments here are
						# ordered according to
						# how <man:kdig(1)> says
						# they should be
						# ordered.

						local to_run=( kdig )
						## [common-settings]
						### [query_class] SKIPED
						### [query_type]
						to_run+=( "$type" )
						### [@server]
						if [ "$server" != "" ]
						then
							to_run+=(
								"@$server"
							)
						fi
						### [options]
						to_run+=( "-$ipv" )
						to_run+=( "+short" )
						if [ "$tp" = udp ]
						then
							to_run+=(
								+notcp
							)
						elif [ "$tp" = tcp ]
						then
							to_run+=( +tcp )
						else
							# shellcheck disable=SC1111
							echo_raw \
								"ERROR:" \
								"Unkown" \
								"transport" \
								"protocol:" \
								"“$tp”." \
								"This" \
								"should" \
								"never" \
								"happen," \
								"even" \
								"when" \
								"tests" \
								"fail."
						fi
						## [query]
						### name
						to_run+=( "$domain" )
						### [settings] SKIPED

						# Add a blank line for
						# spacing.
						echo
						echo_raw \
							'$' \
							"''\${to_run[*]}"
						actual="$(
							"''\${to_run[@]}"
						)"
						kdig_es="$?"

						# If there’s more than
						# one record of a given
						# type, then the order
						# in which they’re
						# printed is probably
						# arbitrary. Either way
						# we don’t really care
						# about the order, we
						# just care about the
						# values. Sorting the
						# output means that
						# there will be a known
						# order.
						actual="$(
							echo_raw "$actual" |
								sort
						)"
						echo_raw "$actual"
						echo_raw \
							"kdig exit" \
							"status:" \
							"$kdig_es"
						if [ "$kdig_es" -ne 0 ]
						then
							exit_status="$kdig_es"
						fi
						if [ "$actual" != "$expectation" ]
						then
							# shellcheck disable=SC1111
							echo_raw \
								"That" \
								"previous" \
								"command" \
								"should" \
								"have" \
								"printed" \
								"“$expectation”."
							if [ "$exit_status" -eq 0 ]
							then
								exit_status=1
							fi
						fi
					done
				done
			done

			return "$exit_status"
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

		function dns_glue_records
		{
			local exit_status=0

			local -r super_dns_servers=(
				ns-64-a.gandi.net
				ns-114-b.gandi.net
				ns-242-c.gandi.net
			)
			local ns_pattern
			ns_pattern='test\.jasonyundt\.email\..+IN\s+NS\s+mailserver\.test\.jasonyundt\.email\.'
			readonly ns_pattern
			local a_pattern
			a_pattern='mailserver\.test\.jasonyundt\.email\..+IN\s+A\s+46\.226\.105\.243'
			readonly a_pattern
			local aaaa_pattern
			aaaa_pattern='mailserver\.test\.jasonyundt\.email\..+IN\s+AAAA\s+2001:4b98:dc0:43:f816:3eff:fe58:92cc'
			readonly aaaa_pattern
			local -r patterns=(
				"$ns_pattern"
				"$a_pattern"
				"$aaaa_pattern"
			)
			local -r n=/dev/null

			local to_run out kdig_es grep_es
			for dns_server in "''\${super_dns_servers[@]}"
			do
				for ipv in 4 6
				do
					to_run=(
						kdig
						NS
						@"$dns_server"
						-"$ipv"
						test.jasonyundt.email
					)
					echo # Blank line for spacing
					echo_raw '$' "''\${to_run[@]}"
					out="$("''\${to_run[@]}" 2>&1)"
					kdig_es="$?"

					echo_raw "$out"
					echo_raw \
						"kdig exit status:" \
						"$kdig_es"
					if [ "$exit_status" -eq 0 ]
					then
						exit_status="$kdig_es"
					fi
					for pattern in "''\${patterns[@]}"
					do
						to_run=(
							grep
							-P
							"$pattern"
						)
						echo_raw '$' "''\${to_run[@]}"
						echo_raw "$out" |
							"''\${to_run[@]}" > "$n"
						grep_es="$?"
						echo_raw \
							"grep exit" \
							"status:" \
							"$grep_es"
						if [ "$exit_status" -eq 0 ]
						then
							exit_status="$grep_es"
						fi
					done

				done
			done

			return "$exit_status"
		}

		function dns_records
		{
			local exit_status=0

			local -a domains types check_locals expectations

			domains+=( test.jasonyundt.email )
			types+=( NS )
			check_locals+=( 1 )
			expectations+=(
				mailserver.test.jasonyundt.email.
			)

			domains+=( mailserver.test.jasonyundt.email )
			types+=( A )
			check_locals+=( 1 )
			expectations+=( 46.226.105.243 )

			domains+=( mailserver.test.jasonyundt.email )
			types+=( AAAA )
			check_locals+=( 1 )
			expectations+=(
				2001:4b98:dc0:43:f816:3eff:fe58:92cc
			)

			# Make sure that the IP addresses that we’re
			# using for DNS recursive resolvers are
			# accurate.
			domains+=( ${esa rr.domain } )
			types+=( A )
			check_locals+=( 0 )
			expectations+=( ${esa (
				builtins.concatStringsSep
					"\n"
					rr.expectedARecords
			) } )

			domains+=( ${esa rr.domain } )
			types+=( AAAA )
			check_locals+=( 0 )
			expectations+=( ${esa (
				builtins.concatStringsSep
					"\n"
					rr.expectedAAAARecords
			) } )

			local -r total="''\${#expectations[@]}"
			# Normally, I would indent the condition of this
			# if statement (because it’s split up over
			# multiple lines), but doing that messes up the
			# way that Neovim indents things.
			if
			[ "$total" -ne "''\${#domains[@]}" ] ||
			[ "$total" -ne "''\${#check_locals[@]}" ]
			[ "$total" -ne "''\${#types[@]}" ]
			then
				# shellcheck disable=SC1110
				echo \
					ERROR: the domains, types and \
					expectations arrays aren’t all \
					same size. This should never \
					happen, even when tests \
					fail. 1>&2
			fi

			local -a to_run
			local to_run_es
			for ((i = 0; i < "$total"; i++))
			do
				check_dns_record \
					"''\${domains[$i]}" \
					"''\${types[$i]}" \
					"''\${check_locals[$i]}" \
					"''\${expectations[$i]}"
				to_run_es="$?"
				if [ "$exit_status" -eq 0 ]
				then
					exit_status="$to_run_es"
				fi
			done
			return "$exit_status"
		}


		function reverse_dns_records
		{
			local exit_status=0

			local -r expected=mailserver.test.jasonyundt.email.
			local -r to_check=(
				46.226.105.243
				2001:4b98:dc0:43:f816:3eff:fe58:92cc
			)
			local actual kdig_es

			for ipv in 4 6
			do
				for address in "''\${to_check[@]}"
				do
					local to_run=(
						kdig
						+short
						-"$ipv"
						-x "$address"
					)
					actual="$("''\${to_run[@]}" 2>&1)"
					kdig_es="$?"
					if \
						[ "$kdig_es" -ne 0 ] \
						&& [ "$exit_status" -eq 0 ]
					then
						exit_status="$kdig_es"
					fi

					echo_raw '$' "''\${to_run[@]}"
					echo_raw "$actual"
					echo_raw "Exit status: $kdig_es"

					if [ "$actual" != "$expected" ]
					then
						# shellcheck disable=SC1111
						echo_raw \
							That \
							previous \
							command \
							should have \
							printed \
							"“$expected”."
						if [ "$exit_status" -eq 0 ]
						then
							exit_status=1
						fi
					fi
				done
			done

			exit "$exit_status"
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

		test_names+=( "DNS glue records" )
		test_logs+=( "$(dns_glue_records 2>&1)" )
		test_exit_statuses+=( "$?" )

		test_names+=( "DNS records" )
		test_logs+=( "$(dns_records 2>&1)" )
		test_exit_statuses+=( "$?" )

		test_names+=( "Reverse DNS records" )
		test_logs+=( "$(reverse_dns_records 2>&1)" )
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
