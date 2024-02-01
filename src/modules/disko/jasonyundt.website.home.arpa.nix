# SPDX-License-Identifier: LicenseRef-MIT-Disko
# SPDX-FileCopyrightText: 2022 Nix community projects
# SPDX-FileCopyrightText: 2024 Jason Yundt <jason@jasonyundt.email>
# SPDX-FileAttributionText: Adapted from <https://github.com/nix-community/disko/blob/aef9a509db64a081186af2dc185654d78dc8e344/example/simple-efi.nix>.
{
	imports = [ ./common.nix ];
	disko.devices.disk.main = {
		device = "/dev/disk/by-path/virtio-pci-0000:04:00.0";
		type = "disk";
		content = {
			type = "gpt";
			partitions = {
				ESP = {
					type = "EF00";
					size = "500M";
					content = {
						type = "filesystem";
						format = "vfat";
						mountpoint = "/boot";
					};
				};
				swap = {
					size = "2G";
					content.type = "swap";
				};
				root = {
					size = "100%";
					content = {
						type = "filesystem";
						format = "ext4";
						mountpoint = "/";
					};
				};
			};
		};
	};
}
