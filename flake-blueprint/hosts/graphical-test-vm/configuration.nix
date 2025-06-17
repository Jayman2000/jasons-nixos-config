# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
{
  config,
  flake,
  inputs,
  lib,
  modulesPath,
  perSystem,
  pkgs,
  ...
}:
{
  system.stateVersion = "25.05";

  imports = [
    flake.nixosModules.first-boot
    flake.nixosModules.graphical-test-vm-common
    flake.nixosModules.home-manager
  ];

  disko.devices.disk.main = {
    device = "/dev/disk/by-path/pci-0000:04:00.0";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        # TODO: Potentially start using spaces in partition names,
        # depending on how this issue [1] gets resolved.
        #
        # [1]: <https://github.com/nix-community/disko/issues/1053>
        #"EFI System Partition" = {
        efiSystemPartiton = {
          # editorconfig-checker-disable
          # Source: <https://uefi.org/specs/UEFI/2.11/05_GUID_Partition_Table_Format.html#defined-gpt-partition-entry-partition-type-guids>
          # editorconfig-checker-enable
          type = "C12A7328-F81F-11D2-BA4B-00A0C93EC93B";
          size = "1G";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        #"NixOS Root" = {
        nixosRoot = {
          # editorconfig-checker-disable
          # Source: <https://uapi-group.org/specifications/specs/discoverable_partitions_specification>
          # editorconfig-checker-enable
          type = "4F68BCE3-E8CD-4DB1-96E7-FBCAF984B709";
          end = "-24G";
          content = {
            type = "filesystem";
            format = "bcachefs";
            mountpoint = "/";
          };
        };
        nixosSwap = {
          # editorconfig-checker-disable
          # Source: <https://uapi-group.org/specifications/specs/discoverable_partitions_specification>
          # editorconfig-checker-enable
          type = "0657fd6d-a4ab-43c4-84e5-0933c84b4f4f";
          size = "100%";
          content.type = "swap";
        };
      };
    };
  };

  boot = {
    # These next two were suggested by nixos-generate-config.
    initrd.availableKernelModules = [
      "ahci"
      "virtio_blk"
      "virtio_pci"
      "virtio_scsi"
      "xhci_pci"
    ];
    kernelModules = [ "kvm-amd" ];
  };

  programs = {
    git.enable = true;
    tmux.enable = true;
  };
  environment.systemPackages =
    let
      fvpPackages = inputs.forge-view-preview.packages;
    in
    [
      pkgs.elinks
      pkgs.man-pages
      pkgs.man-pages-posix
      fvpPackages."${config.nixpkgs.hostPlatform.system}".default
    ];
  documentation = {
    dev.enable = true;
    man.generateCaches = true;
    nixos.includeAllModules = true;
  };
}
