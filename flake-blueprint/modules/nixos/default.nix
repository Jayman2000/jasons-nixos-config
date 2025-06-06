# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
/**
  Common options that apply to all configurations in this repository.
*/
{
  inputs,
  lib,
  perSystem,
  pkgs,
  ...
}:
{
  nixpkgs.hostPlatform = "x86_64-linux";
  nix = {
    package = perSystem.self.nix;
    settings.use-xdg-base-directories = true;
  };

  imports = [
    inputs.disko.nixosModules.default
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
    kernelPackages = lib.mkForce pkgs.linuxPackages_6_14;
  };
  users.defaultUserShell = perSystem.self.nushell;
}
