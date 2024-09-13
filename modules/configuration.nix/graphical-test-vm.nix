# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2024 Jason Yundt <jason@jasonyundt.email>
{ pkgs, modulesPath, ... }:
{
    imports = [
        (modulesPath + "/profiles/qemu-guest.nix")
        ../imports/common.nix
    ];
    boot.loader.efi.canTouchEfiVariables = true;
    fileSystems = {
        "/" = {
            device = "UUID=c304403c-6ce0-4157-a079-2cbb6fb01b9c";
            fsType = "bcachefs";
        };
        "/boot" = {
            device = "/dev/disk/by-uuid/1358-F1E8";
            fsType = "vfat";
            options = [ "fmask=0022" "dmask=0022" ];
        };
    };
}
