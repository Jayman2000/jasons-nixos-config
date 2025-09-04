# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
/**
  Configuration for the Nix package manager.
*/
{
  config,
  lib,
  perSystem,
  ...
}:
{
  nix = {
    package = perSystem.self.nix;
    settings = {
      trusted-users = lib.modules.mkIf (lib.attrsets.hasAttr "jayman" config.users.users) [
        config.users.users.jayman.name
      ];
      use-xdg-base-directories = true;
      # This is supposed to be one gibibyte in bytes.
      download-buffer-size = 1024 * 1024 * 1024;
    };
  };
}
