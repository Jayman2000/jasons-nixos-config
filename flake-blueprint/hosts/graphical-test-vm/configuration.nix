# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
{ inputs, modulesPath, ... }:
{
  system.stateVersion = "25.05";
  nixpkgs.hostPlatform = "x86_64-linux";

  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    inputs.disko.nixosModules.default
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
          size = "100%";
          content = {
            type = "filesystem";
            format = "bcachefs";
            mountpoint = "/";
          };
        };
      };
    };
  };

  boot = {
    loader.systemd-boot.enable = true;
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
}
