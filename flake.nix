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
                packages = [
                    pkgs.git
                ];
            };
        };
    };
}
