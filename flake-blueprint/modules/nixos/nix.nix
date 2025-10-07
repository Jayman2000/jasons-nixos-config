# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
/**
  Configuration for the Nix package manager.
*/
{
  config,
  lib,
  perSystem,
  ...
}:
{
  nix = {
    package = perSystem.self.nix;

    # The main goal of using a flake for my NixOS config is to make things more
    # reproducible. Channels lead to less reproducibility so I’m disabling
    # them.
    channel.enable = false;

    distributedBuilds = true;
    buildMachines = [
      {
        hostName = "Jason-Desktop-Linux";
        maxJobs = 12;
        sshUser = "jayman";
        supportedFeatures = [ "big-parallel" ];
        systems = [
          "i686-linux"
          "x86_64-linux"
        ];
      }
    ];

    settings = {
      trusted-users = lib.modules.mkIf (lib.attrsets.hasAttr "jayman" config.users.users) [
        config.users.users.jayman.name
      ];
      use-xdg-base-directories = true;
      # This is supposed to be one gibibyte in bytes.
      download-buffer-size = 1024 * 1024 * 1024;
    };
  };
}
