# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
{ flake, ... }:
{ lib, pkgs, ... }:
{
  systemd.services.setProfilePicture = {
    path = with pkgs; [
      jq
      systemd
    ];
    script =
      let
        system = pkgs.hostPlatform.system;
        flakePackages = flake.packages."${system}";
        profilePicturePackage = flakePackages.profile-picture;
        profilePicture = "${profilePicturePackage}/image.png";
      in
      ''
        set -o errexit -o nounset -o pipefail

        readonly user_object_path="$(busctl \
          --json=short \
          call \
          -- \
          org.freedesktop.Accounts \
          /org/freedesktop/Accounts \
          org.freedesktop.Accounts \
          FindUserByName \
          s jayman \
            | jq --raw-output .data[0]
        )"

        printf 'User object path: %s\n' "$user_object_path"

        # This part is a modified version of the command that appears in
        # this Reddit comment [1].
        #
        # editorconfig-checker-disable
        # [1]: <https://old.reddit.com/r/linuxquestions/comments/qfcfob/changing_profile_picture_of_a_user_via_terminal/hhys289>
        # editorconfig-checker-enable
        busctl call \
          org.freedesktop.Accounts \
          "$user_object_path" \
          org.freedesktop.Accounts.User \
          SetIconFile \
          s ${lib.strings.escapeShellArg profilePicture}
      '';
    wantedBy = [ "graphical.target" ];
  };
}
