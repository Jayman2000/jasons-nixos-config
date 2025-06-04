# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
{
  inputs,
  lib,
  modulesPath,
  perSystem,
  pkgs,
  ...
}:
{
  system.stateVersion = "25.05";
  nixpkgs.hostPlatform = "x86_64-linux";
  nix = {
    package = perSystem.self.nix;
    settings.use-xdg-base-directories = true;
  };

  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    inputs.disko.nixosModules.default
  ];

  # I use bcachefs on Jason-Desktop-Linux. Bcachefs was added to Linux
  # in Linux version 6.7 [1]. This means that I need to use Linux
  # version 6.7 or greater.
  #
  # Unfortunately, I can’t just use any kernel version that’s greater
  # than or equal to 6.7. Specifically, I tried using Linux 6.12.x, and
  # it made Jason-Desktop-Linux take over five hours to boot. I want to
  # switch back to NixOS’s default Linux kernel version, but I can’t
  # until the default Linux kernel version is greater than or equal to
  # 6.14 (I haven’t done extensive testing, but I believe that 6.14 is
  # the first version of Linux where my desktop will take less than five
  # hours to boot).
  #
  # With all of that in mind, here’s the process that should be followed
  # whenever the Linux kernel version is changed:
  #
  # 1. Check to see if NixOS’s default version of Linux is greater than
  # or equal to 6.14. If it is, then make this next line use the default
  # version of Linux.
  #
  # 2. Check <https://www.kernel.org/category/releases.html> to see if
  # there’s any LTS kernels with version numbers greater than or equal
  # to 6.14. If there are, then use the LTS kernel with the lowest
  # version number that’s greater than or equal to 6.14.
  #
  # 3. Otherwise, use the kernel that’s in Nixpkgs that has the lowest
  # version number that’s greater than or equal to 6.14.
  #
  # editorconfig-checker-disable
  # [1]: <https://lore.kernel.org/lkml/CAHk-=widprp4XoHUcsDe7e16YZjLYJWra-dK0hE1MnfPMf6C3Q@mail.gmail.com/>
  # editorconfig-checker-enable
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_14;

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

  users.defaultUserShell = perSystem.self.nushell;
}
