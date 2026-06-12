# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2026 Jason Yundt <jason@jasonyundt.email>
/**
  Common options that apply to all configurations in this repository that use
  disko.
*/
{ inputs, ... }:
{
  imports = [ inputs.disko.nixosModules.default ];

  # TODO: I don’t think that this next part should be necessary. I think that
  # there’s some sort of bug with the version of disko that I’m using.
  image.modules.disko-unattended-install-iso.boot.supportedFilesystems.bcachefs = true;
}
