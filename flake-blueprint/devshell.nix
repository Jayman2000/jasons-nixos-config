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

    pkgs.pre-commit
    # Dependencies for pre-commit hooks:
    pkgs.nodejs
    pkgs.cargo
  ];
  shellHook = ''
    exec nu --execute '
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
