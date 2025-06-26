# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
{
  flake,
  perSystem,
  pkgs,
  mkShell ? pkgs.mkShellNoCC,
}:
mkShell {
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
      pkgs.systemd
    ];
  shellHook = ''
    exec nu --execute '
      $env.NIX_CONFIG = "
        extra-experimental-features = nix-command flakes
        accept-flake-config = true
        allow-unsafe-native-code-during-evaluation = true
      "
      def --wrapped n [...rest] {
        (
          nix
            ...$rest
        )
      }
      def --wrapped nr [run_as_root: bool, flake_url: string, ...rest] {
        mut command = [ ]
        if $run_as_root {
          $command ++= [
            "run0"
            "--setenv=NIX_CONFIG"
            "--"
            # This next part is needed or else you might get this error
            # when running nr:
            #
            # > evaluation warning: The pinned version of Nix may not
            # >                     have been used to evaluate this
            # >                     flake.
            #
            # TODO: After we switch to a version of Nixpkgs that doesn’t
            # have this bug [1], this next part should be changed so
            # that we use run0’s --setenv option instead of using the
            # env command.
            #
            # [1]: <https://github.com/NixOS/nixpkgs/issues/420570>
            "env"
            $"PATH=($env.PATH | str join ":")"
          ]
        }
        $command ++= [
          "nix"
          "run"
          $"($flake_url).config.system.build.nixos-rebuild"
          "--"
        ]
        run-external ...$command ...$rest
      }
    '
  '';
}
