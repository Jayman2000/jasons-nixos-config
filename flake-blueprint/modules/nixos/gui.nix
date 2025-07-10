# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
{ flake, ... }:
{ pkgs, ... }:
{
  imports = [ flake.nixosModules.profile-picture ];
  /**
    The first few options in this section were taken from
    [here](https://wiki.nixos.org/wiki/KDE#Plasma_6).
  */
  services = {
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    desktopManager.plasma6.enable = true;
  };

  environment.systemPackages = [
    pkgs.keepassxc
  ];
}
