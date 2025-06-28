# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
/**
  Home Manager configuration that’s applies to all jayman user accounts
  on all NixOS configurations that use Home Manager.
*/
{ flake, ... }:
{ pkgs, ... }:
{
  imports = [ flake.homeModules.web-browsers ];
  home.file = {
    versionControlDirectory = {
      recursive = true;
      # These next two lines are a workaround for this issue:
      # <https://github.com/nix-community/home-manager/issues/2104>
      target = "Documents/Home/VC/.keep";
      text = "";
    };
    personalLocalDirectory = {
      recursive = true;
      target = "Documents/Home/local/.keep";
      text = "";
    };
  };
  manual.html.enable = true;
}
