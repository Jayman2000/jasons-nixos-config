# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
{ pkgs }:
pkgs.mkShellNoCC {
  name = "shell-for-working-on-jasons-nixos-config";
  packages = with pkgs; [
    pre-commit
    # Dependencies for pre-commit hooks:
    nodejs
    cabal-install
    ghc
  ];
}
