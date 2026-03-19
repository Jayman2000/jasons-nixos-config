# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
{ config, pkgs, ... }:
{
  environment.systemPackages = [ pkgs.transmission_4-qt ];
  services.transmission = {
    enable = true;
    openPeerPorts = true;
    package = pkgs.transmission_4;
    # This next part tells Transmission to require the use of encryption [1].
    #
    # [1]: <https://github.com/transmission/transmission/blob/4.0.6/docs/Editing-Configuration-Files.md#misc>
    settings.encryption = 2;
  };
  users.users.jayman.extraGroups = [ config.services.transmission.group ];
}
