# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
/**
  A NixOS module that provides common Home Manager–related configuration
  that applies to all NixOS configurations that use Home Manager.
*/
{ flake, inputs }:
{ config, ... }:
{
  imports = [ inputs.home-manager.nixosModules.default ];

  home-manager = {
    # This normally defaults to false. Setting to true means that we
    # won’t have to evaluate Nixpkgs an extra time when evaluating NixOS
    # configurations in this repository.
    useGlobalPkgs = true;
    users.root = flake.homeModules.root;
    sharedModules =
      let
        homeModule = {
          home.stateVersion = config.system.stateVersion;
        };
      in
      [ homeModule ];
  };
}
