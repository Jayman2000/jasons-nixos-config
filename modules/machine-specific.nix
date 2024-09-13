# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2024 Jason Yundt <jason@jasonyundt.email>
{ lib, machineSlug, modulesPath, ... }:

# Normally, I would make machineSlug an option, but you can’t do
# conditional imports with options. Conditional imports with options
# cause infinite recursion.
assert lib.asserts.assertOneOf "machineSlug" machineSlug [
    "graphical-test-vm"
];

let
    isGVT = machineSlug == "graphical-test-vm";
in {
    imports = lib.lists.optional
        isGVT (modulesPath + "/profiles/qemu-guest.nix");
    config = lib.attrsets.optionalAttrs isGVT {
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
        networking.hostName = "Graphical-Test-VM";
    };
}
