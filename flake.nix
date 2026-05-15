# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025–2026 Jason Yundt <jason@jasonyundt.email>
{
  description = "Tools for deploying NixOS the way that I do";
  inputs = {
    # TODO: We’re only using nixos-unstable-small in order to avoid this bug
    # [1]. Once that bug is fixed in nixos-unstable, we should switch to using
    # nixos-unstable.
    #
    # [1]: <https://github.com/NixOS/nixpkgs/issues/513546>
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    blueprint = {
      url = "github:numtide/blueprint";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "jasons-nix-flake-style-guide/systems";
      };
    };
    jasons-nix-flake-style-guide = {
      # editorconfig-checker-disable
      url = "git+https://codeberg.org/JasonYundt/jasons-nix-flake-style-guide.git";
      # editorconfig-checker-enable
      inputs = {
        blueprint.follows = "blueprint";
        nixpkgs.follows = "nixpkgs";
      };
    };
    systems.follows = "jasons-nix-flake-style-guide/systems";
    disko = {
      url = "github:nix-community/disko?ref=refs/tags/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    forge-view-preview = {
      # editorconfig-checker-disable
      url = "git+https://codeberg.org/JasonYundt/forge-view-preview.git";
      # editorconfig-checker-disable
      inputs = {
        blueprint.follows = "blueprint";
        jasons-nix-flake-style-guide.follows = "jasons-nix-flake-style-guide";
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
      };
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    nur = {
      url = "github:nix-community/NUR";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs = {
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };
  outputs =
    inputs:
    inputs.blueprint {
      inherit inputs;
      prefix = "flake-blueprint";
      nixpkgs.config = {
        allowBroken = false;
        warnUndeclaredOptions = true;
      };
    };
}
