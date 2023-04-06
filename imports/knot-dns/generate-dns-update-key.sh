#!/usr/bin/env bash
# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2023)
set -e

function echo_err
{
	printf '%s\n' "$*" 1>&2
}

function print
{
	printf '%s' "$*"
}

readonly name=updater
readonly outdir=/var/dns-update-key
readonly tmpdir="$outdir"-new
readonly secret_regex="(?<=secret: ).*(?=\n)"
readonly conf="$tmpdir/knot.conf"

keymgr --tsig "$name" > "$conf"

secret="$(grep -P "$secret_regex" "$conf")"
readonly secret

print "$name" > "$tmpdir/name"
print "$secret" > "$tmpdir/secret"

rm -rf "$outdir"
mv "$tmpdir" "$outdir"
chown -R root:dns-updater "$outdir"
chmod -R u=r,g=r,o= "$outdir"
