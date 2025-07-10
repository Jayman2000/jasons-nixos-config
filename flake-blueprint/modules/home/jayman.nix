# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
/**
  Home Manager configuration that’s applies to all jayman user accounts
  on all NixOS configurations that use Home Manager.
*/
{ flake, ... }:
{ pkgs, ... }:
{
  imports = with flake.homeModules; [
    plasma
    web-browsers
  ];
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

  programs = {
    gh = {
      enable = true;
      settings.git_protocol = "ssh";
    };
    vesktop = {
      enable = true;
      settings = {
        discordBranch = "stable";
        tray = false;
        minimizeToTray = false;
        hardwareAcceleration = true;
        hardwareVideoAcceleration = true;
        arRPC = false;
        enableSplashScreen = false;
        # I don’t really know what this next one is, so I’m turning it
        # off.
        appBadge = false;
      };
    };
  };
}
