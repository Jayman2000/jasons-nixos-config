# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
/**
  Common options that apply to all configurations in this repository.
*/
{
  flake,
  inputs,
  lib,
  perSystem,
  pkgs,
  ...
}:
{
  system.configurationRevision = flake.rev or "Not available";
  nixpkgs.hostPlatform = "x86_64-linux";

  imports = [
    inputs.disko.nixosModules.default
    flake.nixosModules.custom-date-format
    flake.nixosModules.nix
  ];

  boot.loader.systemd-boot = {
    enable = true;
    edk2-uefi-shell.enable = true;
  };
  networking.networkmanager.enable = true;
  users.defaultUserShell = perSystem.self.shell-shim;
  environment.systemPackages = [
    # Normally, we wouldn’t need to explictly add Nushell to our PATH. We only
    # need to add it because we’re using shell-shim.
    perSystem.self.nushell

    pkgs.wget
  ];

  # This is a workaround for this issue [1]. After a fix for that issue
  # makes it into the version of Nixpkgs that we use, this next part
  # should be removed.
  #
  # [1]: <https://github.com/NixOS/nixpkgs/issues/361592>
  security.pam.services.systemd-run0 = { };

  services.automatic-timezoned.enable = true;
}
