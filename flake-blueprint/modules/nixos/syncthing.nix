# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
{ config, lib, ... }:
let
  dataDir = config.services.syncthing.dataDir;
  syncthingGroup = config.services.syncthing.group;
in
{
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    settings = {
      devices = {
        # editorconfig-checker-disable
        Server.id = "QZBHFNE-XJWGGY4-6JXYMD3-D3HVGR2-C64BVH2-6M644XU-RSVRGAS-QZ752Q7";
        # editorconfig-checker-enable
      };
      folders."Keep Across Linux Distros!" = {
        devices = [ "Server" ];
        id = "syrpl-vpqnk";
        path = "~/.save";
      };
      options.urAccepted = 1;
    };
    # This prevents the default folder from being created.
    #
    # editorconfig-checker-disable
    # Source:
    # <https://wiki.nixos.org/wiki/Syncthing#Disable_default_sync_folder>.
    # editorconfig-checker-enable
    extraFlags = [ "--no-default-folder" ];
  };
  users.users.jayman.extraGroups = [ syncthingGroup ];
  # This allows anyone in the syncthingGroup group to modify the synced
  # folders.
  systemd = {
    tmpfiles.settings."10-syncthing"."${dataDir}"."d".mode = "0770";
    services.syncthing.serviceConfig.UMask = "7007";
  };
}
