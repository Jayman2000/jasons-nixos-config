# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
{
  flake,
  perSystem,
  pkgs,
  pname,
}:
pkgs.writers.writeNuBin pname
  {
    makeWrapperArgs = [
      "--prefix"
      "PATH"
      ":"
      "${pkgs.lib.strings.makeBinPath [ perSystem.self.disko-install ]}"
      "--prefix"
      "PATH"
      ":"
      "${pkgs.lib.strings.makeBinPath [ perSystem.self.nix ]}"
      "--set"
      "flake_url"
      (builtins.flakeRefToString {
        type = "path";
        path = ../..;
      })
    ];
  }
  ''
    def --wrapped n [...rest] {
      (
        nix
          --extra-experimental-features "nix-command flakes"
          --allow-unsafe-native-code-during-evaluation
          ...$rest
      )
    }

    def main [config_name: string, create_image: bool, path?: string] {
      # editorconfig-checker-disable
      let config_url = $"($env.flake_url)#nixosConfigurations.install-($config_name)"
      # editorconfig-checker-enable

      if $create_image {
        if $path != null {
          error make {
            # editorconfig-checker-disable
            msg: "When create_image is true, you must not specify a path."
            # editorconfig-checker-enable
          }
        }
        n build $"($config_url).config.system.build.diskoImages"
      } else {
        if $path == null {
          error make {
            msg: "When create_image is false, you must specify a path."
          }
          (
            n run
              $"($env.flake_url)#disko-install"
              --flake $config_url
              --disk main $path
          )
        }
      }
    }
  ''
