#!/usr/bin/env nix-shell
#! nix-shell -i bash -p coreutils -p mkpasswd
# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
set -eu

readonly generated_dir="src/generated"
readonly prompts=( "Password" "Retype password" )
machine_slugs=( )
for directory in src/modules/configuration.nix/*
do
	machine_slug="$(basename "$directory")"
	passwords_dir="$generated_dir/passwords/$machine_slug"
	for user in root jayman
	do
		password_file="$passwords_dir/$user"
		if [ ! -e "$password_file" ]
		then
			mkdir --parents "$passwords_dir"
			unset final_password
			while [ ! -v final_password ]
			do
				for i in 0 1
				do
					prompt="${prompts[$i]}"
					read \
						-rs \
						-p "[$machine_slug] $prompt for $user: " \
						"password_$i"
					echo
				done
				if [ "$password_0" = "$password_1" ]
				then
					final_password="$password_0"
				else
					echo "ERROR: Passwords don’t match." 1>&2
				fi
			done
			mkpasswd "$final_password" > "$password_file"
		fi
	done
done

chmod --recursive u=rwX,g=,o= "$generated_dir"
