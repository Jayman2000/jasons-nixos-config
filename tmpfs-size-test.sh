#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bc
# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
# After running this test, you should probably reboot.

function is_ram_constrained
{
	(
		[ "${tmp_dir:0:5}" = "/run/" ] && \
		[ "${tmp_dir:0:10}" != "/run/user/" ]
	) || (
		[ "${tmp_dir:0:5}" = "/dev/" ] && \
		[ "${tmp_dir:0:9}" != "/dev/shm/" ]
	)
}

tmpfs_roots=("/dev" "/dev/shm" "/run" "/run/user/1001")
tmp_dirs=( )
for root in "${tmpfs_roots[@]}"
do
	tmp_dir="$(sudo mktemp -dp "$root")"
	sudo chown jayman:users "$tmp_dir"
	tmp_dirs+=("$tmp_dir")
done

echo "${tmp_dirs[@]}"

one_mib_in_bytes="$((1024*1024))"
one_mib_in_kib="1024"
total_ram="$(free -bw | head -n 2 | tail -n 1 | awk '{print $2}')"
portion_of_total_ram_in_mib="$(echo "0.425 * $total_ram / $one_mib_in_bytes" | bc)"

for tmp_dir in "${tmp_dirs[@]}"
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
