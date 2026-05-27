# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025–2026 Jason Yundt <jason@jasonyundt.email>
/**
  Configuration for the Nix package manager.
*/
let
  mkBuildMachineModule =
    { hostName, maxJobs }:
    (
      { config, lib, ... }:
      {
        nix.buildMachines = lib.modules.mkIf (config.networking.hostName != hostName) [
          {
            inherit hostName maxJobs;
            sshUser = "jayman";
            supportedFeatures = [ "big-parallel" ];
            systems = [
              "i686-linux"
              "x86_64-linux"
            ];
          }
        ];
      }
    );
in
{
  config,
  lib,
  perSystem,
  ...
}:
{
  imports = [
    (mkBuildMachineModule {
      hostName = "Jason-Desktop-Linux";
      maxJobs = 12;
    })
    (mkBuildMachineModule {
      hostName = "Jason-Lemur-Pro";
      maxJobs = 8;
    })
  ];

  nix = {
    package = perSystem.self.nix;

    # The main goal of using a flake for my NixOS config is to make things more
    # reproducible. Channels lead to less reproducibility so I’m disabling
    # them.
    channel.enable = false;

    distributedBuilds = true;

    settings = {
      trusted-users = lib.modules.mkIf (lib.attrsets.hasAttr "jayman" config.users.users) [
        config.users.users.jayman.name
      ];
      use-xdg-base-directories = true;
      # This is supposed to be one gibibyte in bytes.
      download-buffer-size = 1024 * 1024 * 1024;
      # This next setting results in better error messages and less builds that
      # get canceled partway through.
      keep-going = true;
    };
  };
}
