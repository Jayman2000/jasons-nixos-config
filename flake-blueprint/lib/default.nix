# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
{ flake, inputs, ... }:
{
  installableConfigurationNames =
    let
      inherit (inputs.nixpkgs) lib;
      configurationNames = builtins.attrNames flake.nixosConfigurations;
      filterFunction = name: !(lib.strings.hasPrefix "install-" name);
    in
    lib.lists.filter filterFunction configurationNames;
}
