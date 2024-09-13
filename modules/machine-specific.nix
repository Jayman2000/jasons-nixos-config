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
        networking.hostName = "Graphical-Test-VM";
    };
}
