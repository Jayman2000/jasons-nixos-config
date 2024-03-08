# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022, 2024)
{ config, pkgs, lib, ... }:
{
	virtualisation.libvirtd.enable = true;
	programs.virt-manager.enable = true;
	# This next part makes sure that VMs created on Graphical-Test-VM can
	# access the Internet. Without this next part, libvirt would use the
	# default network configuration. The default network configuration gives
	# VMs IP addresses that start with 192.168.122. Graphical-Test-VM is a
	# VM, so its own IP address starts with 192.168.122. As a result, it
	# can’t give VMs IP addresses that start with 192.168.122 because that
	# range is already being used by its own network adapter.
	systemd.tmpfiles.settings."libvirt-default-network-files" = let
		networksDir = "/var/lib/libvirt/qemu/networks";
		defaultNetworkFile = "${networksDir}/default.xml";
		isSystemVM = config.jnc.machineSlug == "graphical-test-vm";
	in lib.attrsets.optionalAttrs isSystemVM {
		"${defaultNetworkFile}"."L+".argument = let
			libvirtNetworkForBareMetal = "${pkgs.libvirt}${defaultNetworkFile}";
			libvirtNetworkForGuest = let
				originalFile = "${lib.strings.escapeShellArg libvirtNetworkForBareMetal}";
				newFilePackage = pkgs.runCommand "libvirt-network-for-guest" { } ''
					sed \
						s/192.168.122/192.168.123/g \
						${originalFile} \
						> "$out"
					'';
				newFilePath = "${newFilePackage}";
			in newFilePath;
		in libvirtNetworkForGuest;
	};
}
