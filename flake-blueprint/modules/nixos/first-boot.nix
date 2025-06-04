# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2024–2025 Jason Yundt <jason@jasonyundt.email>
{
  config,
  lib,
  pkgs,
  ...
}:
{
  systemd.services.ensure-root-has-password = {
    wantedBy = [ "multi-user.target" ];
    wants = [ "getty-pre.target" ];
    before = [ "getty-pre.target" ];
    description = "Potentially prompt for a root password";
    script =
      let
        resholvedScript =
          # editorconfig-checker-disable
          pkgs.resholve.writeScript "ensure-root-has-password-resholved-script"
            # editorconfig-checker-enable
            {
              inputs = with pkgs; [
                coreutils
                dbus
                shadow
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
              ];
            }
            ''
              set -o errexit -o nounset -o pipefail
              readonly marker=~root/initial-password-set

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
                      echo Please enter a password for root.
                      if passwd root
                      then
                          echo Successfully set root password.
                          touch "$marker"
                          break
                      else
                          >&2 echo \
                              There was an error setting the password. \
                              Please try again.
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
