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
  system.configurationRevision = flake.rev;
  nixpkgs.hostPlatform = "x86_64-linux";
  nix = {
    package = perSystem.self.nix;
    settings.use-xdg-base-directories = true;
  };

  imports = [
    inputs.disko.nixosModules.default
    flake.nixosModules.custom-date-format
  ];

  boot = {
    loader.systemd-boot.enable = true;
    # I use bcachefs on Jason-Desktop-Linux. Bcachefs was added to Linux
    # in Linux version 6.7 [1]. This means that I need to use Linux
    # version 6.7 or greater.
    #
    # Unfortunately, I can’t just use any kernel version that’s greater
    # than or equal to 6.7. Specifically, I tried using Linux 6.12.x,
    # and it made Jason-Desktop-Linux take over five hours to boot. I
    # want to switch back to NixOS’s default Linux kernel version, but I
    # can’t until the default Linux kernel version is greater than or
    # equal to 6.14 (I haven’t done extensive testing, but I believe
    # that 6.14 is the first version of Linux where my desktop will take
    # less than five hours to boot).
    #
    # With all of that in mind, here’s the process that should be
    # followed whenever the Linux kernel version is changed:
    #
    # 1. Check to see if NixOS’s default version of Linux is greater
    # than or equal to 6.14. If it is, then make this next line use the
    # default version of Linux.
    #
    # 2. Check <https://www.kernel.org/category/releases.html> to see if
    # there’s any LTS kernels with version numbers greater than or equal
    # to 6.14. If there are, then use the LTS kernel with the lowest
    # version number that’s greater than or equal to 6.14.
    #
    # 3. Otherwise, use the kernel that’s in Nixpkgs that has the lowest
    # version number that’s greater than or equal to 6.14.
    #
    # editorconfig-checker-disable
    # [1]: <https://lore.kernel.org/lkml/CAHk-=widprp4XoHUcsDe7e16YZjLYJWra-dK0hE1MnfPMf6C3Q@mail.gmail.com/>
    # editorconfig-checker-enable
    kernelPackages = lib.mkForce pkgs.linuxPackages_6_15;
  };
  networking.networkmanager.enable = true;
  users.defaultUserShell = perSystem.self.shell-shim;
  # Normally, we wouldn’t need to explictly add Nushell to our PATH. We
  # only need to add it because we’re using shell-shim.
  environment.systemPackages = [ perSystem.self.nushell ];

  # This is a workaround for this issue [1]. After a fix for that issue
  # makes it into the version of Nixpkgs that we use, this next part
  # should be removed.
  #
  # [1]: <https://github.com/NixOS/nixpkgs/issues/361592>
  security.pam.services.systemd-run0 = { };

  services.automatic-timezoned.enable = true;
}
