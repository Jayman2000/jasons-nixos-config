# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025–2026 Jason Yundt <jason@jasonyundt.email>
{
  services.openssh = {
    enable = true;
    settings = {
      # Disabling password authentication is good for security.
      PasswordAuthentication = false;
      # Disabling root login is also good for security.
      PermitRootLogin = "no";
    };
    knownHosts = {
      # This next part is needed or else Nix won’t allow you to use
      # Jason-Desktop-Linux as a remote builder.
      Jason-Desktop-Linux.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMLFsPPiGBoxMwtJz1FDZHagmJh2jDSiFYPr89+gdWV";
      # This next part is needed or else Nix won’t allow you to use
      # Jason-Lemur-Pro as a remote builder.
      Jason-Lemur-Pro.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOhcFlQL6H5Cp4m0Imc8k55xbUQ5a39lhcUew9VoQGid";
    };
  };
  users.users.jayman.openssh.authorizedKeys.keys = [
    # editorconfig-checker-disable
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINtGh8BdxRt7Pu3J82SIjzOWRCnuqpHpzYSmlMcCXaBO jayman@Graphical-Test-VM"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILC3F4rFOhk7jKm5/0S4KnJma+gz3vM6Cn3Vo8TTY3CA root@Graphical-Test-VM"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILWQkgb4A4mvzHeXAm6ghxfknl15cttipb56qP0IpBlj jayman@Jason-Desktop-Linux"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIClHCYdk1dsNMnTm4J2saSiy/7YkK3KKr0S5TfJqynYv root@Jason-Desktop-Linux"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP5Zve4N1Oxbsx0J7a85U3jtiPgR+di3nX094KLiTgdn jayman@Jason-Lemur-Pro"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ6ZinXpsymSnj3QCpwnjSEXuXktxuUczqRFun/M4LMQ root@Jason-Lemur-Pro"
    # editorconfig-checker-enable
  ];
}
