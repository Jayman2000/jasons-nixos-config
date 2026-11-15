# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2026 Jason Yundt <jason@jasonyundt.email>
{ pkgs, pname }:
pkgs.resholve.writeScriptBin pname
  {
    interpreter = pkgs.lib.meta.getExe pkgs.bash;
    inputs = with pkgs; [
      gh
      jq
      nix
    ];
    execer = [
      "cannot:${pkgs.lib.meta.getExe pkgs.nix}"
      "cannot:${pkgs.lib.meta.getExe pkgs.gh}"
    ];
  }
  ''
    set -o errexit -o nounset -o pipefail

    are_there_any_outdated_inputs=0

    flake_metadata="$(
      nix \
        --extra-experimental-features 'nix-command flakes' \
        flake metadata \
          --json
    )"
    readonly flake_metadata

    function check_argument_number {
      # See <man:sysexits.h(3head)>.
      local -r EX_SOFTWARE=70

      local -r error_message='ERROR: the %q function should always be called with %q arguments, but it was actually called with %q arguments.\n'

      local -r correct_argument_number_for_check_argument_number=3

      if [ "$#" -ne "$correct_argument_number_for_check_argument_number" ]
      then
        >&2 printf \
          "$error_message" \
          check_argument_number \
          "$correct_argument_number_for_check_argument_number" \
          "$#"
        exit "$EX_SOFTWARE"
      fi

      local -r other_function="$1"
      local -r correct_argument_number_for_other_function="$2"
      local -r actual_argument_number_for_other_function="$3"

      if [ "$correct_argument_number_for_other_function" -ne "$actual_argument_number_for_other_function" ]
      then
        >&2 printf \
          "$error_message" \
          "$other_function" \
          "$correct_argument_number_for_other_function" \
          "$actual_argument_number_for_other_function"
        exit "$EX_SOFTWARE"
      fi
    }

    function get_data_about_input {
      check_argument_number get_data_about_input 2 "$#"

      local -r input="$1"
      local -r jq_filter="$2"

      printf '%s' "$flake_metadata" \
        | jq \
          --raw-output \
          --arg input "$input" \
          '.locks.nodes.[$input] | '"$jq_filter"
    }

    function check_for_latest_github_release {
      check_argument_number get_data_about_input 1 "$#"
      local -r input="$1"

      local owner
      owner="$(get_data_about_input "$input" .original.owner)"
      readonly owner

      local repo
      repo="$(get_data_about_input "$input" .original.repo)"
      readonly repo

      local latest_release_ref
      latest_release_ref="$(
        gh release view --repo "$owner/$repo" --json tagName | jq --raw-output .tagName
      )"
      latest_release_ref="refs/tags/$latest_release_ref"
      readonly latest_release_ref

      local currently_used_ref
      currently_used_ref="$(
        get_data_about_input "$input" .original.ref
      )"

      if [ "$latest_release_ref" != "$currently_used_ref" ]
      then
        local -r message='The %q flake input is outdated. The latest GitHub release for that flake input is %q, but the release that we’re currently using is %q.\n'
        printf "$message" "$input" "$latest_release_ref" "$currently_used_ref"
        are_there_any_outdated_inputs=1
      fi
    }

    # TODO: This won’t be needed if we ever end up using a version of Nix that
    # has this feature request [1] implemented.
    #
    # [1]: <https://github.com/NixOS/nix/issues/11946>
    check_for_latest_github_release steam-config-nix

    if [ "$are_there_any_outdated_inputs" -eq 0 ]
    then
      echo None of the JNC flake’s inputs need to be manually updated.
      echo Finished updating version numbers that are pinned in .nix files.
    else
      exit 1
    fi
  ''
