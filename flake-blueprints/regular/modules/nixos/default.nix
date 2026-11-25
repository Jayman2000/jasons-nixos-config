# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025–2026 Jason Yundt <jason@jasonyundt.email>
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
    flake.nixosModules.custom-date-format
    flake.nixosModules.nix
  ];

  boot = {
    loader.systemd-boot = {
      enable = true;
      edk2-uefi-shell.enable = true;
    };
    # It can take a while to mount a bcachefs filesystem after an unclean
    # shutdown. Sometimes, it takes so long to mount the root bcachefs
    # filesystem after an unclean shutdown that the systemd unit for mounting
    # the root filesystem fails. I’m increasing the default timeout to an
    # absurdly hight number in order to prevent that from happening.
    initrd.systemd.settings.Manager.DefaultTimeoutStartSec = 60 * 60;
  };

  networking.networkmanager.enable = true;
  users.defaultUserShell = perSystem.self.shell-shim;
  environment.systemPackages = [
    # Normally, we wouldn’t need to explictly add Nushell to our PATH. We only
    # need to add it because we’re using shell-shim.
    perSystem.self.nushell

    pkgs.smem
    pkgs.wget
  ];
  programs.htop.enable = true;

  services.automatic-timezoned.enable = true;
}
