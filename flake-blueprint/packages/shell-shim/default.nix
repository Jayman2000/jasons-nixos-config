# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
{
  perSystem,
  pkgs,
  pname,
}:
pkgs.rustPlatform.buildRustPackage (finalAttrs: {
  inherit pname;
  version =
    let
      cargoManifest = pkgs.lib.trivial.importTOML ./Cargo.toml;
    in
    cargoManifest.package.version;
  src = ./.;
  cargoHash = "sha256-8ZRUwctoD2FpQyzeknFB1GpMCWEKxLliJSkPeHFUvJc=";

  nativeBuildInputs = [
    pkgs.pkg-config
  ];
  buildInputs = [
    pkgs.openssl
  ];

  bashPath = pkgs.lib.meta.getExe pkgs.bash;
  desiredShellPath = pkgs.lib.meta.getExe perSystem.self.nushell;

  # This is needed or else you’ll get an error if you try to set
  # users.defaultUserShell [1] to this package.
  #
  # editorconfig-checker-disable
  # [1]: <https://nixos.org/manual/nixos/stable/options#opt-users.defaultUserShell>
  # editorconfig-checker-enable
  passthru.shellPath = "/bin/shell-shim";

  meta = {
    description = "Make Nushell a more effective login shell";
    longDescription = ''
      If you use Nushell as a login shell on NixOS, then certain NixOS
      features won’t work properly. For example, I tried to set
      `programs.ssh.startAgent` to `true` in my NixOS config, but it
      didn’t work properly. When you set `programs.ssh.startAgent` to
      true, [it’s supposed to potentially set the `SSH_AUTH_SOCK`
      environment variable][1]. The code that potentially sets that
      environment variable only gets run if you use a more traditional
      shell. If you use a less traditional shell like Nushell, then the
      code won’t get run.

      `shell-shim` helps work around that problem. Specifically,
      `shell-shim` will use Bash to launch Nushell. Bash will set all of
      the environment variables that are supposed to be set before it
      lauches Nushell. This effectively side-steps most (all?) issues
      that are caused by using Nushell as a login shell.

      If `shell-shim` is run with no command-line arguments, then it
      will use Bash to launch Nushell as described above. However, if
      `shell-shim` is given any command-line arguments, then it will not
      lauch Nushell at all. Instead, it will just launch Bash with all
      of the the command-line arguments that were given to `shell-shim`.
      The idea here is to make sure that `shell-shim` doesn’t break code
      that looks like this:

      ```bash
      "$USERS_LOGIN_SHELL" -c '. script.sh'
      ```

      If someone wrote code that runs the user’s login shell with a few
      command-line arguments, then they probably expect the login shell
      to be a traditional shell and not something like Nushell.

      ${
        "" # editorconfig-checker-disable
      }

      [1]: https://github.com/NixOS/nixpkgs/blob/b2485d56967598da068b5a6946dadda8bfcbcd37/nixos/modules/programs/ssh.nix#L398-L402

      ${
        "" # editorconfig-checker-enable
      }
    '';
  };
})
