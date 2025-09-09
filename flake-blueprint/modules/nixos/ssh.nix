# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
{
  services.openssh = {
    enable = true;
    settings = {
      # Disabling password authentication is good for security.
      PasswordAuthentication = false;
      # Disabling root login is also good for security.
      PermitRootLogin = "no";
    };
  };
  users.users.jayman.openssh.authorizedKeys.keys = [
    # editorconfig-checker-disable
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFfXiVplYdjUgnYeldCI2RIMI8afUvM3XnJ8IRZnHnGz jayman@Graphical-Test-VM"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILWQkgb4A4mvzHeXAm6ghxfknl15cttipb56qP0IpBlj jayman@Jason-Desktop-Linux"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGwzCr7V2+t3NBrwztLtRbkeGeb1Fps6jU69E3g7g4OI jayman@Jason-Lemur-Pro"
    # editorconfig-checker-enable
  ];
}
