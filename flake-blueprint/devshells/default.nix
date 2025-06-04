# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
{
  flake,
  perSystem,
  pkgs,
}:
pkgs.mkShellNoCC {
  name = "shell-with-pinned-nix";
  packages =
    let
      # We use secretCode as the name of the script because it’s very
      # unlikely that there would be another command on the user’s path
      # that just so happens to be named secretCode.
      secretCode = builtins.hashString "sha256" "${../..}";
      pinnedNixHint = pkgs.writers.writeNuBin secretCode ''
        echo You’re using the pinned version of Nix.
      '';
    in
    [
      perSystem.self.nix
      perSystem.self.nushell
      pinnedNixHint
    ];
  shellHook = ''
    exec nu --execute '
      def --wrapped n [...rest] {
        (
          nix
            --extra-experimental-features "nix-command flakes"
            --accept-flake-config
            --allow-unsafe-native-code-during-evaluation
            ...$rest
        )
      }
      def --wrapped nr [flake_url: string, ...rest] {
        (
          n run
            $"($flake_url).config.system.build.nixos-rebuild"
            --
            ...$rest
        )
      }
    '
  '';
}
