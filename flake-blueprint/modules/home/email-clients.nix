# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
{ lib, ... }:
{
  accounts.email.accounts =
    let
      commonConfig = {
        realName = "Jason Yundt";
        thunderbird.enable = true;
      };
      gmailSpecificConfig = {
        address = "swagfortress@gmail.com";
        flavor = "gmail.com";
      };
      personalServerAddress = "jason@jasonyundt.email";
      personalServerHost = "box.jasonyundt.email";
      personalServerSpecificConfig = {
        address = personalServerAddress;
        userName = personalServerAddress;
        imap = {
          host = personalServerHost;
          port = 993;
          tls.enable = true;
        };
        smtp = {
          host = personalServerHost;
          port = 465;
          tls.enable = true;
        };
        primary = true;
      };
      verizonAddress = "jayundt@verizon.net";
      verizonSpecificConfig = {
        address = verizonAddress;
        userName = verizonAddress;
        imap = {
          host = "imap.aol.com";
          port = 993;
          tls.enable = true;
        };
        smtp = {
          host = "smtp.aol.com";
          port = 465;
          tls.enable = true;
        };
        thunderbird.settings = id: {
          "mail.smtpserver.smtp_${id}.authMethod" = 10; # 10 = OAuth2
          "mail.server.server_${id}.authMethod" = 10; # 10 = OAuth2
          "mail.server.server_${id}.socketType" = 3; # 3 = SSL/TLS
        };
      };
    in
    {
      gmail = lib.modules.mkMerge [
        commonConfig
        gmailSpecificConfig
      ];
      verizon = lib.modules.mkMerge [
        commonConfig
        verizonSpecificConfig
      ];
      personalServer = lib.modules.mkMerge [
        commonConfig
        personalServerSpecificConfig
      ];
    };
  programs.thunderbird = {
    enable = true;
    profiles.main.isDefault = true;
    settings = {
      # This makes Thunderbird use the “Classic View” layout.
      "mail.pane_config.dynamic" = 0;
      # This makes Thunderbird use the “Table View” instead of the default
      # “Cards View”.
      "mail.threadpane.listview" = 1;
    };
  };
}
