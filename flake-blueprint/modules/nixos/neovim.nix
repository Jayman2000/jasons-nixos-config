# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.wl-clipboard-rs ];
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
}
