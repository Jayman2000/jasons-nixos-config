# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
{
  flake,
  pkgs,
  pname,
  system,
}:
let
  defaultDevShell = flake.devShells."${system}".default;
  firstOverride = defaultDevShell.override {
    # The default dev shell uses mkShellNoCC. For this dev shell we need
    # to use regular mkShell because one of this repository’s pre-commit
    # hooks depends on a C compiler.
    inherit (pkgs) mkShell;
  };
  secondOverride = firstOverride.overrideAttrs (
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
          cargo
          rustc
        ]);
    }
  );
in
secondOverride
