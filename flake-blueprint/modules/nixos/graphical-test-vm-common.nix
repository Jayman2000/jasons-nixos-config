# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
/**
  Configuration that is shared by both the graphical-test-vm and the
  install-graphical-test-vm configurations.
*/
{ flake, ... }:
{ modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    flake.nixosModules.default
    flake.nixosModules.serial-console
  ];
}
