# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
{ flake, ... }:
{
  imports = with flake.nixosModules; [
    flake.nixosModules.graphical-test-vm-common
    flake.nixosModules.installer
  ];

  jnc.configToInstallName = "graphical-test-vm";
}
