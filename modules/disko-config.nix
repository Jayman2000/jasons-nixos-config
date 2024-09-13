# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2024 Jason Yundt <jason@jasonyundt.email>
{ lib, machineSlug, ... }:
lib.attrsets.optionalAttrs (machineSlug == "graphical-test-vm") {
    disko.devices.disk.main = {
        device = "/dev/disk/by-path/virtio-pci-0000:04:00.0";
        type = "disk";
        content = {
            type = "gpt";
            partitions = {
                ESP = {
                    end = "512M";
                    type = "EF00";
                    content = {
                        type = "filesystem";
                        format = "vfat";
                        mountpoint = "/boot";
                    };
                };
                root = {
                    end = "-0";
                    content = {
                        type = "filesystem";
                        format = "bcachefs";
                        mountpoint = "/";
                    };
                };
            };
        };
    };
}
