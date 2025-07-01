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
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
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
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
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
    let
      originalOutputs = inputs.blueprint {
        inherit inputs;
        prefix = "flake-blueprint";
        nixpkgs.config = {
          allowBroken = false;
          warnUndeclaredOptions = true;
        };
      };
      warningMessage = ''
        The pinned version of Nix may not have been used to evaluate
        this flake. Before using anything in this flake, you should
        always make sure that you’re using the pinned version of Nix by
        running this command:
        ${
          "" # editorconfig-checker-disable
        }
          nix --extra-experimental-features "nix-command flakes" develop [flake URL]
      '';
      # editorconfig-checker-enable
      warn = inputs.nixpkgs.lib.trivial.warn warningMessage;
      supportedSystems = import inputs.systems;
      packagesForNixItself = builtins.map (
        system: originalOutputs.packages."${system}".nix
      ) supportedSystems;
      packagesForNushell = builtins.map (
        system: originalOutputs.packages."${system}".nushell
      ) supportedSystems;
      defaultDevShells = builtins.map (
        system: originalOutputs.devShells."${system}".default
      ) supportedSystems;
      # editorconfig-checker-disable
      noWarnValues = packagesForNixItself ++ packagesForNushell ++ defaultDevShells;
      # editorconfig-checker-enable
      addWarningsHelper =
        name: value:
        (
          if builtins.isAttrs value then
            if inputs.nixpkgs.lib.attrsets.isDerivation value then
              # editorconfig-checker-disable
              if builtins.elem value noWarnValues then value else warn value
            # editorconfig-checker-enable
            else
              addWarnings value
          else
            warn value
        );
      addWarnings = builtins.mapAttrs addWarningsHelper;
      outputsWithWarnings = addWarnings originalOutputs;

      flakeRoot = "${./.}";
      # The secretCode was chosen for a specific reason. See the comment
      # about pinnedNixHint in flake-blueprint/devshells/default.nix.
      secretCode = builtins.hashString "sha256" flakeRoot;
      jnfsgLib = inputs.jasons-nix-flake-style-guide.lib;
      currentFlakeURL = jnfsgLib.flakeURL { input = flakeRoot; };
      commandToCheckForDevShell = [
        "nix"
        "--extra-experimental-features"
        "nix-command flakes"

        # This one helps make sure that we don’t accidentally do
        # infinite recursion.
        "--no-allow-unsafe-native-code-during-evaluation"

        "run"
        "${currentFlakeURL}#nushell"
        "--"
        "--commands"
        "which ${secretCode} | is-not-empty"
      ];
      exec = builtins.exec or (ignored: false);
      usingShellWithPinnedNix = exec commandToCheckForDevShell;
    in
    # editorconfig-checker-disable
    if usingShellWithPinnedNix then originalOutputs else outputsWithWarnings;
  # editorconfig-checker-enable
}
