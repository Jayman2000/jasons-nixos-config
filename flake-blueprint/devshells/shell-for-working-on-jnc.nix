# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
{
  flake,
  pkgs,
  pname,
  system,
}:
flake.devShells."${system}".default.overrideAttrs (
  final: prev: {
    name = pname;
    nativeBuildInputs =
      prev.nativeBuildInputs
      ++ (with pkgs; [
        pre-commit
        # Dependencies for pre-commit hooks:
        nodejs
        cabal-install
        ghc
      ]);
  }
)
