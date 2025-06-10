# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
{
  config,
  flake,
  modulesPath,
  ...
}:
{
  imports = [
    flake.nixosModules.graphical-test-vm-common
    flake.nixosModules.installer
  ];

  jnc.configToInstallName = "graphical-test-vm";
}
