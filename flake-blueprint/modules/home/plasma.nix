# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
{ inputs, ... }:
{ ... }:
{
  imports = [ inputs.plasma-manager.homeManagerModules.plasma-manager ];
  programs.plasma = {
    enable = true;
    overrideConfig = true;
    session.general.askForConfirmationOnLogout = false;
  };
}
