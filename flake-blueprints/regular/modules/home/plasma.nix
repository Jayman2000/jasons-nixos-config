# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
{ inputs, ... }:
{ ... }:
{
  imports = [ inputs.plasma-manager.homeModules.plasma-manager ];
  programs.plasma = {
    enable = true;
    overrideConfig = true;

    workspace.lookAndFeel = "org.kde.breezedark.desktop";

    fonts =
      let
        defaultFontSettings = {
          family = "Noto Serif";
          pointSize = 10;
        };
      in
      {
        general = defaultFontSettings;
        fixedWidth = defaultFontSettings // {
          family = "Source Code Pro";
        };
        small = defaultFontSettings // {
          pointSize = 8;
        };
        toolbar = defaultFontSettings;
        menu = defaultFontSettings;
        windowTitle = defaultFontSettings;
      };
    input.keyboard.options = [ "compose:menu" ];
    session.general.askForConfirmationOnLogout = false;
    panels = [
      {
        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.pager"
          "org.kde.plasma.icontasks"
          "org.kde.plasma.systemtray"
          {
            digitalClock = {
              date = {
                enable = true;
                format = "isoDate";
              };
            };
          }
        ];
      }
    ];
    kwin.nightLight = {
      enable = true;
      mode = "times";
      time = {
        morning = "05:30";
        evening = "21:00";
      };
      transitionTime = 60;
    };
  };
}
