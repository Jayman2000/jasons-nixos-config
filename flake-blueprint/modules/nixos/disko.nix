# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2026 Jason Yundt <jason@jasonyundt.email>
/**
  Common options that apply to all configurations in this repository that use
  disko.
*/
{ inputs, ... }:
{
  imports = [ inputs.disko.nixosModules.default ];

  image.modules.disko-unattended-install-iso = {
    # I want to avoid using channels as much as possible. Additionally, I think
    # that avoiding copying a channel will make installs finish faster.
    disko.unattendedInstall.extraNixOSInstallArgs = [ "--no-channel-copy" ];
    # Hopefully, disabling compression will make it so that building the ISO
    # image is faster and that installing files off of the ISO is faster.
    isoImage.squashfsCompression = null;
    # TODO: I don’t think that this next part should be necessary. I think that
    # there’s some sort of bug with the version of disko that I’m using.
    boot.supportedFilesystems.bcachefs = true;
  };
}
