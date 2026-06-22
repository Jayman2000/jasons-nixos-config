# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025–2026 Jason Yundt <jason@jasonyundt.email>
{
  flake,
  perSystem,
  pkgs,
}:
pkgs.mkShell {
  name = "shell-for-working-on-jnc";
  packages = [
    perSystem.self.nushell
    pkgs.systemd
    pkgs.flamegraph

    pkgs.pre-commit
    # Dependencies for pre-commit hooks:
    pkgs.nodejs
    pkgs.cargo
  ]
  # This next one doesn’t work on i686-linux.
  ++ pkgs.lib.lists.optional (!pkgs.stdenv.hostPlatform.isx86_32) pkgs.kdePackages.isoimagewriter;
  shellHook = ''
    exec nu --execute '
      def --wrapped nr [run_as_root: bool, flake_url: string, ...rest] {
        mut command = [ ]
        if $run_as_root {
          $command ++= [
            "run0"
            "--setenv=NIX_CONFIG"
            "--"
          ]
        }
        $command ++= [
          "nix"
          "--extra-experimental-features"
          "nix-command flakes"
          "run"
          $"($flake_url).config.system.build.nixos-rebuild"
          "--"
        ]
        run-external ...$command ...$rest
      }
    '
  '';
}
