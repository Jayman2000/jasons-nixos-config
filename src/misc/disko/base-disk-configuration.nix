# SPDX-License-Identifier: LicenseRef-MIT-Disko
# SPDX-FileCopyrightText: 2022 Nix community projects
# SPDX-FileCopyrightText: 2024 Jason Yundt <jason@jasonyundt.email>
# SPDX-FileAttributionText: Adapted from <https://github.com/nix-community/disko/blob/aef9a509db64a081186af2dc185654d78dc8e344/example/simple-efi.nix>.
{ swapSize
, deviceName ? "main"
, devicePath ? "/dev/disk/by-path/virtio-pci-0000:04:00.0"
# The disko command will pass an extra argument if the disk configuration is a
# function instead of a set [1]. We don’t care about that argument, so we’re
# using “...” to ignore it.
#
# [1]: <https://github.com/nix-community/disko/blob/fe064a639319ed61cdf12b8f6eded9523abcc498/disko#L136>
, ...
}:

{
	imports = [ ../../modules/disko/common.nix ];
	disko.devices.disk."${deviceName}" = {
		type = "disk";
		device = devicePath;
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
					content.type = "swap";
					size = swapSize;
				};
				root = {
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
}
