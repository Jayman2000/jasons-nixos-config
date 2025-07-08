<!--
SPDX-License-Identifier: CC0-1.0
SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
-->

# How to Install NixOS Using a Config from This Repo

If you want to do a fresh install of NixOS using a configuration from
this repository, then here’s what you need to do:

1. Open a terminal.

1. Make sure that you have the Nix package manager installed by running
this command:

    ```nushell
    nix-env --version
    ```

    If that command finishes successfully, then you have the Nix package
    manager installed. If that command gives you an error, then you need
    to install the Nix package manager.

1. If you’re going to install NixOS on physical hardware, then make sure
that you have the `udisksctl` command installed by running this command:

    ```nushell
    udisksctl help
    ```

    If that command finishes successfully, then you have `udisksctl`
    installed. If that command gives you an error, then you need to
    install `udisksctl` (but only if you’re installing NixOS on physical
    hardware).

1. Make sure that you have a copy of this repository on your system.

1. Change directory into the root of this repository by running this
command:

    ```nushell
    cd <path to repository>
    ```

1. Start this repository’s flake’s default dev shell by running this
command:

    ```nushell
    nix --extra-experimental-features 'nix-command flakes' develop
    ```

1. Get a list of NixOS configurations that this repository provides by
running this command:

    ```nushell
    n eval .#lib.installableConfigurationNames
    ```

1. Choose which of those configurations you want to use.

1. If you’re going to install NixOS on physical hardware, then attach a
USB drive to your system and write down the path to its device file.

1. Create an install medium by doing one of the following:

    - If you’re installing NixOS on physical hardware, then turn the USB
    drive into an install medium by running this command:

        ```nushell
        (
            n run .#create-install-medium
                --
                    <config name>
                    false
                    <path to USB device file>
        )
        ```

    - If you’re installing NixOS on a virtual machine, then generate a
    disk image that will function as an install medium by running this
    command:

        ```nushell
        (
            n run .#create-install-medium
                --
                    <config name>
                    true
                    <path to where you want the image file to be>
        )
        ```

1. If you’re going to install NixOS on physical hardware, then power-off
the USB drive by running this command:

    ```nushell
    udisksctl power-off --block-device <path to USB device file>
    ```

1. If you’re going to install NixOS on physical hardware, then
physically remove the USB drive from your system.

1. Make sure that the machine that you’re going to install NixOS on is
powered off.

1. Attach the install medium to the machine that you’re going to install
NixOS on.

1. Start booting into the install medium.

1. At the bootloader menu, choose the `unattendedInstall` option.
