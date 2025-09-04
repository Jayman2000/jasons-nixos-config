# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
/**
  Configuration for the Nix package manager.
*/
{ perSystem, ... }:
{
  nix = {
    package = perSystem.self.nix;
    settings.use-xdg-base-directories = true;
  };
}
