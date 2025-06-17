# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
{
  flake,
  inputs,
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
      (inputs.jasons-nix-flake-style-guide.lib.flakeURL {
        input = flake;
      })
    ];
  }
  ''
    $env.NIX_CONFIG = '
      extra-experimental-features = nix-command flakes
      allow-unsafe-native-code-during-evaluation = true
    '

    def main [config_name: string, create_image: bool, path: string] {
      let config_name_encoded = $config_name | url encode --all
      let absolute_path = $path | path expand

      if $create_image {
        # editorconfig-checker-disable
        let config_url = $"($env.flake_url)#nixosConfigurations.install-($config_name_encoded)"
        # editorconfig-checker-enable
        let temp_dir = (
          mktemp
            --suffix -jnc-create-install-medium
            --directory
        )
        cd $temp_dir
        nix build $"($config_url).config.system.build.diskoImages"
        cp result/*.raw $absolute_path
        cd -
        rm --recursive --force $temp_dir
      } else {
        # Annoyingly, the config_url has to be different for the top and
        # bottom half of this if statement.
        let config_url = $"($env.flake_url)#install-($config_name)"
        (
          sudo
            --preserve-env=NIX_CONFIG
            nix run $"($env.flake_url)#disko-install"
              --
                --flake $config_url
                --disk main $absolute_path
        )
      }
    }
  ''
