# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2023)
# After running this test, you should probably reboot.
with import <nixpkgs> { };

resholve.writeScript "tmpfs-size-test" {
	execer = [
		# TODO: This won’t be needed once Nixpkgs contains a
		# version of binlore that contains this commit:
		# <https://github.com/abathur/binlore/commit/c09ae5a2a4bca7a373d349421cd3f5ee7b8f94de>
		"cannot:${procps}/bin/free"
	];
	fake.external = [ "sudo" ];
	inputs = [
		bc
		coreutils
		gawk
		procps
	];
	interpreter = "${bash}/bin/bash";
} ''
	function is_ram_constrained
	{
		(
			[ "''${tmp_dir:0:5}" = "/run/" ] && \
			[ "''${tmp_dir:0:10}" != "/run/user/" ]
		) || (
			[ "''${tmp_dir:0:5}" = "/dev/" ] && \
			[ "''${tmp_dir:0:9}" != "/dev/shm/" ]
		)
	}

	if ! type sudo &> /dev/null
	then
		echo "ERROR: the sudo command isn’t available."
		exit 1
	fi


	tmpfs_roots=("/dev" "/dev/shm" "/run" "/run/user/1001")
	tmp_dirs=( )
	for root in "''${tmpfs_roots[@]}"
	do
		tmp_dir="$(sudo mktemp -dp "$root")"
		sudo chown jayman:users "$tmp_dir"
		tmp_dirs+=("$tmp_dir")
	done

	echo "''${tmp_dirs[@]}"

	one_mib_in_bytes="$((1024*1024))"
	one_mib_in_kib="1024"
	total_ram="$(free -bw | head -n 2 | tail -n 1 | awk '{print $2}')"
	portion_of_total_ram_in_mib="$(echo "0.425 * $total_ram / $one_mib_in_bytes" | bc)"

	for tmp_dir in "''${tmp_dirs[@]}"
	do
		if is_ram_constrained; then
			mibs="$portion_of_total_ram_in_mib"
		else
			mibs="$((39 * $one_mib_in_kib))"
		fi
		for ((i = 0; i < "$mibs"; i++))
		do
			dest="$tmp_dir/$i"
			touch "$dest"
			echo "$dest"
			dd bs=1024 count="$one_mib_in_kib" if=/dev/urandom of="$dest"
		done
	done
''
