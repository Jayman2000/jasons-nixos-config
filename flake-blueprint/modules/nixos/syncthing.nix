# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
{ config, lib, ... }:
let
  dataDir = config.services.syncthing.dataDir;
  syncthingGroup = config.services.syncthing.group;
  /**
    This function is intended to be used with lib.lists.filter.
  */
  isNotVM = deviceName: deviceName != "Graphical-Test-VM";
  /**
    This function is intended to be used with lib.lists.filter.
  */
  isNotCurrentDevice = deviceName: deviceName != config.networking.hostName;
  /**
    The same thing as isNotCurrentDevice, but can be used with lib.attrsets.filterAttrs.
  */
  isNotCurrentDevice' = name: value: (isNotCurrentDevice name);
  folderConfig = {
    devices = lib.lists.filter isNotCurrentDevice [
      "Graphical-Test-VM"
      "Jason-Lemur-Pro"
      "Server"
      "TNAS Server"
    ];
    # This setting helps prevent errors when syncthing. Plus, I don’t
    # really want permissions to synchronized anyway.
    ignorePerms = true;
  };
  /**
    Configuration that applies to all systems that use this module.
  */
  unconditionalConfig = {
    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
      settings = {
        gui.tls = true;
        devices = lib.attrsets.filterAttrs isNotCurrentDevice' {
          # editorconfig-checker-disable
          Server.id = "QZBHFNE-XJWGGY4-6JXYMD3-D3HVGR2-C64BVH2-6M644XU-RSVRGAS-QZ752Q7";
          Graphical-Test-VM.id = "DJJPUZU-N5H4PFF-Q5GPFT7-FNQYES4-57SE5SL-NU22RQN-DH2NRVI-XKOMUAN";
          Jason-Lemur-Pro.id = "KQUK7VW-JETKGA2-SPQTBH7-25MGHFI-H5BKM4O-2LDJUYG-HB2NIDQ-WF65SQE";
          "TNAS Server".id = "UI23FM4-44FA7UA-AQLCKDN-VXWF7SO-5WS7VE4-DWNJ4MI-KYKA2TC-CQPWCAM";
          # editorconfig-checker-enable
        };
        folders = {
          "Keep Across Linux Distros!" = folderConfig // {
            id = "syrpl-vpqnk";
            path = "~/.save";
          };
          "Game Data" = folderConfig // {
            id = "eheef-uq5hv";
            path = "~/Game Data";
          };
        };
        options.urAccepted = 3;
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
    # This allows anyone in the syncthingGroup group to modify the
    # synced folders. It also ensures that any files or folders created
    # in the synced folders are owned by the syncthingGroup group.
    systemd = {
      tmpfiles.settings."10-syncthing"."${dataDir}"."d".mode = "2770";
      services.syncthing.serviceConfig.UMask = "7007";
    };
    # This next part should be removed after we switch to a version of
    # Nixpkgs that has this pull request [1] merged into it.
    #
    # [1]: <https://github.com/NixOS/nixpkgs/pull/422094>
    environment.systemPackages = [ config.services.syncthing.package ];
  };
  notOnVM = config.networking.hostName != "Graphical-Test-VM";
  /**
    Configurations that only apply to physical systems that use this
    module.
  */
  nonVMConfig = {
    services.syncthing.settings.folders.Projects = folderConfig // {
      devices = lib.lists.filter isNotVM folderConfig.devices;
      id = "mjwge-zeznc";
      path = "~/Projects";
    };
  };
in
{
  config = lib.modules.mkMerge [
    unconditionalConfig
    (lib.modules.mkIf notOnVM nonVMConfig)
  ];
}
