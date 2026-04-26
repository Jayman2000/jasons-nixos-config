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
      "Jason-Desktop-Linux"
      "Jason-Desktop-Windows"
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
          Graphical-Test-VM.id = "MK4T7K3-CIYQR3E-PBXE5JM-5MPWPHV-65PM66C-7DURQDD-3MATNB5-J24F4QH";
          Jason-Desktop-Linux.id = "N3YVKHB-DZBB7WJ-MXIFZWB-3IZNV6E-4JCCG46-ZE7FIBD-K57IB3L-3LNBPAO";
          Jason-Desktop-Windows.id = "IJ7DGZZ-HEOL43C-4RCWITD-QCATRWR-HPTWFR3-XTTYEZW-QUV4CBL-5P7AGQF";
          Jason-Lemur-Pro.id = "FBN7V4Q-JGER7TM-KX246K5-7OO53AI-QE7JLDO-ARYVMP2-GP5ZZQR-72246QK";
          "TNAS Server".id = "IOPU45L-EYRCENI-BXXWAWP-UUSPAIX-VIRXRCN-4TMHVAD-C3V3LEV-VY4HTQZ";
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
