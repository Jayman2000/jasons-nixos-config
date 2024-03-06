# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
{ pkgs, lib, custom }:

let
	caddy = "${lib.strings.escapeShellArg "${pkgs.caddy}/bin/caddy"}";
	curl = "${lib.strings.escapeShellArg "${pkgs.curl}/bin/curl"}";
in pkgs.runCommandLocal "caddy-local-ca-files" { } ''
	${custom.bash-preamble.preambleForOthers}
	mkdir data
	declare -xr XDG_DATA_HOME="$PWD/data"

	declare -xr CADDY_ADMIN=unix/./admin.sock
	echo '
		{
			admin {
				# According to the docs, this is the default
				# value for origins [1], but my testing makes it
				# seem like that’s not the case.
				#
				# [1]: <https://caddyserver.com/docs/caddyfile/options#admin>
				origins localhost 127.0.0.1 ::1
			}
			persist_config off
		}
	' > Caddyfile
	${caddy} start
	# If we don’t do this, then Caddy won’t bother generating the
	# certificate files.
	${curl} \
		--output /dev/null \
		--unix-socket ./admin.sock \
		http://localhost/pki/ca/local
	${caddy} stop

	cp --recursive "$XDG_DATA_HOME/caddy/pki/authorities/local" "$out"
''
