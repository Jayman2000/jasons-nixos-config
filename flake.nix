# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2024 Jason Yundt <jason@jasonyundt.email>
{
    description = "The flake for Jason’s NixOS Config";
    nixConfig.pure-eval = true;

    inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    outputs = { self, nixpkgs }: let
        system = "x86_64-linux";
        pkgsForThisFlake = import nixpkgs { inherit system; };
        pinnedNixVersion = pkgsForThisFlake.nix;
    in {
        devShells."${system}" = {
            pinnedNixVersion = pkgsForThisFlake.mkShellNoCC {
                name = "shell-for-jnc-with-pinned-nix-version";
                packages = [ pinnedNixVersion ];
            };
            default = pkgsForThisFlake.mkShellNoCC {
                name = "shell-for-working-on-jasons-nixos-config";
                packages = let
                    # editorconfig-checker-disable
                    customPre-commit = pkgsForThisFlake.pre-commit.override {
                        # One of the pre-commit repos that we use
                        # requires a newer version of Python.
                        python3Packages = pkgsForThisFlake.python312.pkgs;
                    };
                    # editorconfig-checker-enable
                in [
                    customPre-commit
                    pkgsForThisFlake.git
                    pkgsForThisFlake.nixos-rebuild
                    pkgsForThisFlake.nodePackages.livedown
                ];
            };
        };
        nixosConfigurations.graphicalTestVM = nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
                ./modules/imports
            ];
            specialArgs.machineSlug = "graphical-test-vm";
        };
    };
}
