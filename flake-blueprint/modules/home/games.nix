# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
{ inputs, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ inputs.retroarch-nix.hmModules.retroarch ];

  # vkQuake
  # Normally, I would use home.file and mkOutOfStoreSymlink, but I can’t
  # because I’m using a flake [1].
  #
  # [1]: <https://github.com/nix-community/home-manager/issues/7403>
  systemd.user.services =
    let
      serviceName = "dotVkquakeDir";
      scriptName = "${serviceName}-ExecStart";
      source = "/var/lib/syncthing/Game Data/Quake/Original";
      target = "${config.home.homeDirectory}/.vkquake";
    in
    {
      "${serviceName}" = {
        Unit.Description = "Create ${target}";
        Install.WantedBy = [ "default.target" ];
        Service.ExecStart =
          pkgs.resholve.writeScript scriptName
            {
              interpreter = lib.meta.getExe pkgs.bash;
              inputs = with pkgs; [
                coreutils
                xorg.lndir
              ];
            }
            ''
              readonly source=${lib.strings.escapeShellArg source}
              readonly target=${lib.strings.escapeShellArg target}
              if [ -e "$source" ] && [ ! -e "$target" ]
              then
                mkdir --parents "$target"
                lndir -withrevinfo "$source" "$target"
              fi
            '';
      };
    };

  # RetroArch
  programs.retroarch = {
    enable = true;
    cores.mesen.enable = true;
    settings = {
      config_save_on_exit = "false";
      rgui_browser_directory = "/var/lib/syncthing/Game Data/RetroArch";
    };
  };
}
