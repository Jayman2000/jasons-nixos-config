# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2024–2025 Jason Yundt <jason@jasonyundt.email>
{
  config,
  lib,
  pkgs,
  ...
}:
{
  systemd.services.first-boot-setup = {
    wantedBy = [ "multi-user.target" ];
    wants = [ "getty-pre.target" ];
    before = [ "getty-pre.target" ];
    description = "Potentially do first-time setup";
    script =
      let
        inherit (lib.strings) escapeShellArg;
        myUsername = config.users.users.jayman.name;
        opensshBin = lib.attrsets.getBin pkgs.openssh;
        ssh-keygen = "${opensshBin}/bin/ssh-keygen";
        resholvedScript =
          # editorconfig-checker-disable
          pkgs.resholve.writeScript "first-boot-setup-resholved-script"
            # editorconfig-checker-enable
            {
              inputs = with pkgs; [
                coreutils
                dbus
                shadow
                systemd
              ];
              interpreter = lib.meta.getExe pkgs.bash;
              # This is a workaround for this issue [1].
              #
              # editorconfig-checker-disable
              # [1]: <https://github.com/abathur/resholve/issues/29>
              # editorconfig-checker-enable
              fix.passwd = true;
              execer = [
                # TODO: This won’t be needed once this PR [1] is merged
                # and released.
                #
                # editorconfig-checker-disable
                # [1]: <https://github.com/NixOS/nixpkgs/pull/342536>
                # editorconfig-checker-enable
                "cannot:${pkgs.shadow}/bin/passwd"
                # TODO: This won’t be needed once a solution for this
                # issue [1] is found and released.
                #
                # [1]: <https://github.com/abathur/resholve/issues/120>
                "cannot:${pkgs.openssh}/bin/ssh-keygen"
                # TODO: This should be removed after this pull
                # request [1] makes it into the version of resholve that
                # we’re using.
                #
                # [1]: <https://github.com/abathur/resholve/pull/121>
                "cannot:${pkgs.systemd}/bin/run0"
              ];
            }
            ''
              set -o errexit -o nounset -o pipefail
              readonly user=${escapeShellArg myUsername}
              readonly marker=~root/first-boot-setup-performed
              readonly ssh_p1='Enter a passphrase for a new SSH key: '
              readonly ssh_p2='Enter the same passphrase again: '

              function set_systemd_show_status {
                  # I used --print-reply here in order to force
                  # dbus-send to wait for a reply. Waiting for a reply
                  # helps ensure that systemd has finished setting
                  # ShowStatus by the time this function returns.

                  # editorconfig-checker-disable
                  dbus-send \
                      --system \
                      --print-reply \
                      --dest=org.freedesktop.systemd1 \
                      /org/freedesktop/systemd1 \
                      org.freedesktop.systemd1.Manager.SetShowStatus \
                      "string:$*" > /dev/null
                  # editorconfig-checker-enable
              }

              function restore_original_systemd_show_status {
                  # This is supposed to work according to this commit
                  # message [1].
                  #
                  # editorconfig-checker-disable
                  # [1]: <https://github.com/systemd/systemd/commit/0bb007f7a23c41e23481373ded47ee3ddcf8f26b>
                  # editorconfig-checker-enable
                  set_systemd_show_status ""
              }

              if [ ! -e "$marker" ]
              then
                  # If we don’t turn off systemd’s ShowStatus option,
                  # then we’ll run into this problem [1].
                  #
                  # editorconfig-checker-disable
                  # [1]: <https://github.com/systemd/systemd/issues/11447>
                  # editorconfig-checker-enable
                  set_systemd_show_status no

                  while true
                  do
                      echo "Please enter a password for $user."
                      if passwd "$user"
                      then
                          echo "Successfully set $user’s password."
                          touch "$marker"
                          break
                      else
                          >&2 echo \
                              There was an error setting the password. \
                              Please try again.
                      fi
                  done

                  while true
                  do
                      ssh_passphrase=""
                      while [ -z "$ssh_passphrase" ]
                      do
                          read -rsp "$ssh_p1" passphrase_1
                          echo
                          read -rsp "$ssh_p2" passphrase_2
                          echo
                          if [ "$passphrase_1" != "$passphrase_2" ]
                          then
                              >&2 echo \
                                  The two passphrases that you entered \
                                  do not match.
                          elif [ -z "$passphrase_1" ]
                          then
                              >&2 echo \
                                  Empty passphrases are not allowed.
                          else
                              ssh_passphrase="$passphrase_1"
                          fi
                      done
                      # Some of these arguments were only used because
                      # the Codeberg documentation recommends using
                      # them [1].
                      #
                      # TODO: This next part references the ssh-keygen’s
                      # store path directly. That direct store path
                      # reference should be removed after this pull
                      # request [2] makes it into the version of
                      # resholve that we’re using.
                      #
                      # editorconfig-checker-disable
                      # [1]: <https://docs.codeberg.org/security/ssh-key/#generating-an-ssh-key-pair>
                      # [2]: <https://github.com/abathur/resholve/pull/121>
                      # editorconfig-checker-enable
                      if run0 \
                          --user="$user" \
                          -- \
                          ${escapeShellArg ssh-keygen} \
                              -t ed25519 \
                              -a 100 \
                              -N "$ssh_passphrase"
                      then
                          echo Successfully generated a new SSH key.
                          break
                      else
                          >&2 echo \
                              There was an error generating the SSH \
                              key. Please try again.
                      fi
                  done

                  restore_original_systemd_show_status
              fi
            '';
      in
      ''
        exec ${lib.strings.escapeShellArg resholvedScript}
      '';
    serviceConfig = {
      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "tty";
      Type = "oneshot";
    };
  };
}
