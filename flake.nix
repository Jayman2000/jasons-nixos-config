# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
{
  description = "Tools for deploying NixOS the way that I do";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
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
      url = "github:nix-community/disko?tag=latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs:
    inputs.blueprint {
      inherit inputs;
      prefix = "flake-blueprint";
    };
}
