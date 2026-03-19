# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025–2026 Jason Yundt <jason@jasonyundt.email>
{
  flake,
  inputs,
  modulesPath,
  ...
}:
{
  networking.hostName = "Jason-Desktop-Linux";
  system.stateVersion = "22.05";

  imports = [
    flake.nixosModules.workstation
    "${modulesPath}/installer/scan/not-detected.nix"
  ];

  boot = {
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usbhid"
      "uas"
      "sd_mod"
    ];
    kernelModules = [ "kvm-amd" ];
  };

  fileSystems = {
    "/" = {
      device = "UUID=b5aafee4-daa4-495c-863f-f5823735a308";
      fsType = "bcachefs";
    };
    "/boot" = {
      device = "UUID=52D3-0277";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };
  swapDevices = [
    {
      # TODO: Why does “UUID=” not work here?
      device = "/dev/disk/by-uuid/e17575bf-fa97-455c-9831-46e171b5ae53";
    }
  ];
}
