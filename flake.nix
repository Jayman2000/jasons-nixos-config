# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2024 Jason Yundt <jason@jasonyundt.email>
{
    description = "The flake for Jason’s NixOS Config";
    nixConfig.pure-eval = true;

    inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    outputs = { self, nixpkgs }: let
        system = "x86_64-linux";
        pkgs = import nixpkgs { inherit system; };
        pinnedNixVersion = pkgs.nix;
    in {
        devShells."${system}" = {
            pinnedNixVersion = pkgs.mkShellNoCC {
                name = "shell-for-jnc-with-pinned-nix-version";
                packages = [ pinnedNixVersion ];
            };
            default = pkgs.mkShellNoCC {
                name = "shell-for-working-on-jasons-nixos-config";
                packages = let
                    customPre-commit = pkgs.pre-commit.override {
                        # One of the pre-commit repos that we use
                        # requires a newer version of Python.
                        python3Packages = pkgs.python312.pkgs;
                    };
                in [
                    customPre-commit
                    pkgs.git
                    pkgs.nodePackages.livedown
                ];
            };
        };
    };
}
