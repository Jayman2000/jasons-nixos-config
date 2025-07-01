# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
/**
  Configurations that are meant to be run inside a virtual machine
  should use this module.
*/
{ modulesPath, ... }:
{
  # See <https://nixos.org/manual/nixos/stable/#sec-profile-qemu-guest>.
  imports = [ "${modulesPath}/profiles/qemu-guest.nix" ];
  # See <https://wiki.nixos.org/wiki/Virt-manager#Guest_Agent>.
  services = {
    qemuGuest.enable = true;
    spice-vdagentd.enable = true;
  };
}
