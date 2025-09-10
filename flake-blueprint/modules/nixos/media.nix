# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
/**
  Configuration that’s related to playing media.
*/
{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.mpv ];
}
