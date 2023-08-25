# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
with import <nixpkgs> { };

writeShellApplication {
	name = "prs-deserving-review";
	runtimeInputs = [ curl gh jq orcania ];
	text = ''
		readonly es_mkdir_failed=1
		readonly es_curl_failed=2
		readonly es_bad_http_status=3
		# See
		# <https://specifications.freedesktop.org/basedir-spec/0.8/ar01s03.html>.
		readonly XDG_CACHE_HOME="''${XDG_CACHE_HOME:-$HOME/.cache}"
		readonly cache_dir="$XDG_CACHE_HOME/prs-deserving-review"
		readonly alt_svc_file="$cache_dir/alt-svc"
		readonly origin="https://discourse.nixos.org"

		function echo_raw
		{
			printf "%s" "$*"
		}

		function echo_err
		{
			echo_raw "$*"$'\n' 2>&1
		}

		function complain_about_arguments
		{
			maybe_complain_about_arguments \
				complain_about_arguments \
				3 \
				"$#"
			local -r name="$1"
			local -r expected_args="$2"
			local -r actual_args="$3"
			echo_err \
				"WARNING: $name() was called with" \
				"$actual_args arguments. It should" \
				"only ever be called with" \
				"$expected_args arguments."
		}

		function maybe_complain_about_arguments
		{
			local -r my_name=maybe_complain_about_arguments
			local -r my_expected_args=3
			local -r my_actual_args="$#"
			if [ "$my_expected_args" -ne "$my_actual_args" ]
			then
				complain_about_arguments \
					"$my_name" \
					"$my_expected_args" \
					"$my_actual_args"
			fi

			local -r name="$1"
			local -r expected_args="$2"
			local -r actual_args="$3"
			if [ "$expected_args" -ne "$actual_args" ]
			then
				complain_about_arguments \
					"$name" \
					"$expected_args" \
					"$actual_args"
			fi
		}

		function try_mkdir
		{
			maybe_complain_about_arguments \
				try_mkdir \
				1 \
				"$#"
			if ! mkdir -p "$1"
			then
				# shellcheck disable=SC1111
				echo_err \
					"ERROR: Failed to create" \
					"“$1”. This should never" \
					"happen, even if that" \
					"directory already exists."
				exit "$es_mkdir_failed"
			fi
		}

		function url_to_fs_path
		{
			# TODO: Make sure that the folder name isn’t
			# longer than 256 characters.
			echo_raw "$cache_dir/"
			echo_raw "$*" | base64url
		}

		function curl_cached
		{
			maybe_complain_about_arguments \
				curl_cached \
				1 \
				"$#"
			local -r url="$1"
			local -r dest_dir="$(url_to_fs_path "$url")"
			try_mkdir "$dest_dir"

			local cmd=(
				curl
				--silent
				--show-error
				--location
				# Thanks, pvandenberk and Nate Anderson:
				# <https://superuser.com/a/442395/954602>
				--write-out
				"%{http_code}"
				-o
				"$dest_dir/content"
				--alt-svc
				"$alt_svc_file"
				--location
				--etag-save
				"$dest_dir/etag"
				"$url"
			)
			if [ -e "$dest_dir/content" ]
			then
				cmd+=( -z "$dest_dir/content" )
			fi
			if [ -e "$dest_dir/etag" ]
			then
				cmd+=( --etag-compare "$dest_dir/etag" )
			fi

			if ! "''${cmd[@]}" > "$dest_dir/status"
			then
				echo_err \
					"ERROR: The following command" \
					"failed:"
				echo_err "''${cmd[@]}"
				exit "$es_curl_failed"
			fi

			local -r status="$(< "$dest_dir"/status)"
			for allowed_status in 200 203 304
			do
				if [ "$status" -eq "$allowed_status" ]
				then
					return 0
				fi
			done

			# shellcheck disable=SC1111
			echo_err \
				"ERROR: Unexpected HTTP status code" \
				"($status) from “$url”."
			exit "$es_bad_http_status"
		}

		function pr_urls_from_json
		{
			maybe_complain_about_arguments \
				pr_urls_from_json \
				1 \
				"$#"
			local -r json_file="$1"
			local -r filter='.post_stream.posts[].link_counts[]?.url'
			jq \
				--raw-output \
				"$filter" \
				"$json_file" | \
					grep -P '^.*//github.com/.*pull/'
		}

		function posts_in_json
		{
			maybe_complain_about_arguments \
				total_posts_from_json \
				1 \
				"$#"
			local -r json_file="$1"
			jq \
				'.post_stream.posts | length' \
				"$json_file"
		}

		function find_pr_urls
		{
			# See
			# <https://meta.discourse.org/t/fetch-all-posts-from-a-topic-using-the-api/260886>.
			local -r thread_url="$origin/t/3032.json?print=true"
			#curl_cached "$thread_url"
			local current_page_json
			current_page_json="$(url_to_fs_path "$thread_url")/content"
			pr_urls_from_json "$current_page_json"

			local -i total_posts
			total_posts="$(
				jq \
					'.post_stream.stream | length' \
					"$current_page_json"
			)"
			readonly total_posts
			local -i posts_retrived_so_far
			posts_retrived_so_far="$(posts_in_json "$current_page_json")"

			local current_url
			local -i posts_just_retrived
			local -i page_number=2
			while [ "$posts_retrived_so_far" -lt "$total_posts" ]
			do
				echo_err "$page_number"
				# Don’t get rate limited!!!
				sleep 30s

				current_url="$thread_url&page=$page_number"
				#curl_cached "$current_url"
				current_page_json="$(url_to_fs_path "$current_url")/content"
				pr_urls_from_json "$current_page_json"

				posts_just_retrived="$(posts_in_json "$current_page_json")"
				(( post_retrived_so_far+="$posts_just_retrived" ))
				(( page+=1 ))
			done
		}

		# shellcheck disable=SC2119
		# shellcheck disable=SC2120
		function process_pr_urls
		{
			maybe_complain_about_arguments \
				process_pr_urls \
				0 \
				"$#"
			local -r grep=(
				grep
				--only-matching
				--max-count
				1
				--perl-regexp
			)
			local -i open_urls=0
			local -r -i max_urls=5

			local repo pr_number is_open cmd
			while [ "$open_urls" -lt "$max_urls" ] &&  read -r url
			do
				repo="$(echo_raw "$url" | "''${grep[@]}" \
					'(?<=//github\.com/)[^/]*/[^/]*(?=/)'
				)"
				pr_number="$(echo_raw "$url" | "''${grep[@]}" \
					'(?<=pull/)\d*'
				)"
				# Don’t get rate limited.
				sleep 4.5s
				cmd=(gh \
					pr \
					view \
					--repo \
					"$repo" \
					--json \
					state \
					--jq \
					'.state == "OPEN"' \
					"$pr_number"
				)
				if ! is_open="$("''${cmd[@]}")"
				then
					echo_err \
						WARNING: The following \
						command failed:
					echo_err "''${cmd[@]}"
				fi

				if [ "$is_open" = "true" ]
				then
					echo_raw "$url"$'\n'
					(( open_urls+=1 ))
				fi
			done
		}

		try_mkdir "$cache_dir"
		find_pr_urls | process_pr_urls
	'';
}
