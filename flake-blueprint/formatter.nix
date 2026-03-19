# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025–2026 Jason Yundt <jason@jasonyundt.email>
{ inputs, pkgs }:
let
  inherit (inputs.treefmt-nix.lib) evalModule;
  treefmt-nixModule = {
    projectRootFile = "flake.nix";
    programs = {
      nixfmt = {
        enable = true;
        package = pkgs.nixfmt-rfc-style;
      };
      rustfmt = {
        enable = true;
        edition = "2024";
      };
    };
  };
  processedTreefmt-nixModule = evalModule pkgs treefmt-nixModule;
in
processedTreefmt-nixModule.config.build.wrapper
