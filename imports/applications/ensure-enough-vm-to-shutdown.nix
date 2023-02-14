# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
with import <nixpkgs> { };

writeShellApplication {
	name = "ensure-enough-vm-to-shutdown";
	runtimeInputs = [
		bc
		gawk
		jq
		procps
		util-linux
	];
	text = ''
		# Row numbers and column numbers both start at 1.
		function get_value_from_free {
			local row="$1"
			local column="$2"

			result="$(free -bwt | head -n "$row" | tail -n 1 | awk "{print \$$column}")"
		}

		get_value_from_free 2 2
		total_ram="$result"
		one_gib_in_bytes="$((1024*1024*1024))"
		vitrual_memory_threshold="$(("$total_ram" - "$one_gib_in_bytes"))"
		function enough_vm_to_swapoff {
			get_value_from_free 4 2
			local total_vm="$result"
			get_value_from_free 3 4
			local free_swap="$result"
			get_value_from_free 2 8
			local available_ram="$result"
			local usable_virtual_memory
			usable_virtual_memory="$(echo -E "$total_vm - $free_swap - $available_ram" | bc )"

			[ "$usable_virtual_memory" -le "$vitrual_memory_threshold" ]
		}

		function targeted_tmpfs_mount_points
		{
			# This part is complicated, but it essentially says
			# “for each mount_point in the list of all tmpfs mount
			# points.”
			#
			# TODO: Use --nul-output [1] once there’s a stable
			# version of jq that includes that feature.
			# [1]: <https://stedolan.github.io/jq/manual/#Invokingjq>

			local mount_point
			findmnt --json -o target tmpfs | \
				jq -j '.filesystems[].target + "\u0000"' | \
				while read -rd $'\0' mount_point; do
					# We need to exclude /run and
					# /run/wrappers since there’s files in
					# those directories that are needed very
					# late into the shutdown process.
					if
						[ "$mount_point" != "/run" ] && \
						[ "$mount_point" != "/run/wrappers" ]
					then
						# Paths can contain any
						# character except for NUL, so
						# we have to put a NUL at the
						# end of every mount_point to
						# indicate where the mount_point
						# ends.
						echo -ne "$mount_point\x00"
					fi
				done
		}

		function atime_filename_oldest_first
		{
			# Basically says
			# “for each mount_point in targeted_tmpfs_mount_points()”
			local mount_point
			targeted_tmpfs_mount_points | \
				while read -rd $'\0' mount_point; do
					find \
						"$mount_point" \
						-mount \
						-type f \
						-printf '%A@ %p\0'
				done | sort --zero-terminated
		}

		function eecho
		{
			echo -E "$*" 1>&2
		}

		if ! enough_vm_to_swapoff; then
			eecho "WARNING: Too much virtual memory is being used" \
				"by tmpfses. You probably won’t be able to" \
				"shut down until after that memory is freed." \
				"Deleting old files in tmpfses…"

			# Basically says
			# “for each atime_plus_filename in atime_filename_oldest_first()”
			atime_filename_oldest_first |
				while read -rd $'\0' atime_plus_filename; do
					echo -En "$atime_plus_filename" | {
						read -rd ' ' _atime

						# This will cause an error
						# because the delimiter won’t be
						# encountered before stdin
						# reaches end of file. The
						# variable still gets set, so we
						# can ignore the error.
						read -rd ''' filename || true

						rm \
							--force \
							--one-file-system \
							--preserve-root=all \
							--verbose \
							"$filename"
					}
					if enough_vm_to_swapoff; then
						# Consume the rest of stdin. If
						# we don’t do this, then the
						# command that is being piped to
						# this while loop will complain
						# about a broken pipe.
						cat > /dev/null
					fi
				done
		fi
	'';
}
