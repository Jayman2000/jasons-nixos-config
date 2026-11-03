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
  inputs,
  lib,
  pkgs,
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
    package = pkgs.nix;

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
      # This makes it so that machines can copy Nix store paths from remote
      # builders before building starts.
      substituters =
        let
          buildMachineToSubstituterURI =
            value:
            inputs.jasons-nix-flake-style-guide.lib.buildURI-reference {
              scheme = value.protocol;
              userinfo = value.sshUser;
              host = value.hostName;
              # TODO: I don’t think that setting path should be necessary here.
              # If I don’t set it, I get an error, but I don’t think that I
              # should get an error if it is not set (after all, the
              # buildURI-reference function does have a default value for
              # path). I think that there’s a bug with buildURI-reference that
              # should be fixed.
              path = [ "" ];
              # Normally, Nix will refuse to copy Nix store paths from a
              # substituter unless the path is signed by a trusted key. That
              # being said, it will copy store paths from a remote builder even
              # if the path is unsigned. In this situation, I’m declaring that
              # certain machines are both substituters and remote builders.
              # This means that unsigned paths will get copied anyway even if
              # Nix’s substitution process is trying to protect me from them.
              #
              # This next part disables Nix’s normal behavior for these
              # substituters. It makes it so that Nix will indeed copy unsigned
              # paths from these substituters. (Nix will still refuse to copy
              # unsigned paths from other substituters like
              # <https://hydra.nixos.org/> though).
              #
              # You might think that this decreases security, but I don’t
              # really think so. After all, we’re already trusting unsigned
              # paths from these same machines when they are used as remote
              # builders. You could make the argument that we should not trust
              # unsigned paths from remote builders, but I don’t agree with
              # that either. SSH’s know hosts mechanism already helps us make
              # sure that we are connected to the real Jason-Desktop-Linux or
              # the real Jason-Lemur-Pro when we copy paths from them. Nix
              # store path–signature verification would make it so that we
              # double check that we truly are connected to the real
              # Jason-Desktop-Linux or the real Jason-Lemur-Pro every time we
              # copy paths from them. Double checking is good, but in this case
              # it would only increase security negligibly. Additionally, it
              # would mean that I would have to maintain another set of key
              # pairs for Jason-Desktop-Linux and Jason-Lemur-Pro (in addition
              # to their SSH keys). I don’t want to put effort into doing that
              # if there’s going to be basically no gain.
              query = "trusted=1";
            };
        in
        lib.lists.map buildMachineToSubstituterURI config.nix.buildMachines;
    };
  };
}
