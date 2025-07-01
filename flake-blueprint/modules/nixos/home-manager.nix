# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
/**
  A NixOS module that provides common Home Manager–related configuration
  that applies to all NixOS configurations that use Home Manager.
*/
{ flake, inputs }:
{ config, pkgs, ... }:
{
  imports = [ inputs.home-manager.nixosModules.default ];

  # Some of the Home Manager modules depend on these fonts.
  environment.systemPackages = with pkgs; [
    noto-fonts
    source-code-pro
  ];

  home-manager = {
    # This normally defaults to false. Setting to true means that we
    # won’t have to evaluate Nixpkgs an extra time when evaluating NixOS
    # configurations in this repository.
    useGlobalPkgs = true;
    # A few times, I’ve tried to deploy a new version of this
    # repository, and it’s failed because Firefox replaced a symlink
    # with a regular file. Hopefully, setting backupFileExtension will
    # make Home Manager failures less likely.
    backupFileExtension = "backup";

    users.jayman = flake.homeModules.jayman;
    sharedModules =
      let
        homeModule = {
          home.stateVersion = config.system.stateVersion;
        };
      in
      [ homeModule ];
  };
}
