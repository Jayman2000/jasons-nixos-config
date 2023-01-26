# SPDX-License-Identifier: LicenseRef-MIT-NixOSWiki
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
# SPDX-FileAttributionText: Adapted from <https://nixos.wiki/wiki/OSX-KVM>.
{
	virtualisation.libvirtd.enable = true;
	users.extraUsers.jayman.extraGroups = [ "libvirtd" ];

	boot.extraModprobeConfig = ''
		options kvm_intel nested=1
		options kvm_intel emulate_invalid_guest_state=0
		options kvm ignore_msrs=1
	'';
}
