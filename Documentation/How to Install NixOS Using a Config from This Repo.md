<!--
SPDX-License-Identifier: CC0-1.0
SPDX-FileCopyrightText: 2025–2026 Jason Yundt <jason@jasonyundt.email>
-->

# How to Install NixOS Using a Config from This Repo

If you want to do a fresh install of NixOS using a configuration from
this repository, then the first that you need to do is decide whether or
not you will be using the `jason-desktop-linux` NixOS configuration. If
you are going to be using the `jason-desktop-linux` NixOS configuration,
then please follow the instructions at the bottom of this page in the
“Instructions for `jason-desktop-linux`” section. Otherwise, follow the
instructions in the below “Generic instructions” section.

## Generic instructions

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

1. Start this repository’s default dev shell by running this command:

    ```nushell
    nix --extra-experimental-features 'nix-command flakes' develop
    ```

1. Get a list of NixOS configurations that this repository provides by
running this command:

    ```nushell
    (
        nix
            --extra-experimental-features 'nix-command flakes'
            eval
                --apply builtins.attrNames
                .#nixosConfigurations
    )
    ```

1. Choose which of those configurations you want to use.

1. Store your chosen configuration in a variable by running this
command:

    ```nushell
    let config_attr_name = <name of config that you chose>
    ```

1. Create an unattended install ISO file by running this command:

    ```nushell
    (
        nr
        false
        $".#nixosConfigurations.($config_attr_name)"
            build-image
                --flake $".#($config_attr_name)"
                --image-variant disko-unattended-install-iso
    )
    ```

    If that command finishes successfully, then the newly generated
    unattended install ISO file will be located in the `./result/iso/`
    directory.

1. If you’re going to install NixOS on physical hardware, then create a
bootable unattended install USB drive by doing the following:

    1. Attach a USB drive to your system and write down the path to its
    device file.

    1. Open [the KDE ISO Image
    Writer](https://apps.kde.org/isoimagewriter) by running this
    command:

        ```nushell
        isoimagewriter
        ```

        This should cause a GUI application to open.

    1. In the “ISO image” section of the KDE ISO Image Writer window,
    select the unattended install ISO that we generated earlier (it
    should be in the `./result/iso/` directory).

    1. In the “USB drive” section of the KDE ISO Image Writer window,
    select the USB drive that you connected previously.

    1. Click on the “Create” button.

    1. Click on the “Continue” button.

    1. Enter your password when prompted.

    1. Once it successfully finishes writing the unattended install ISO
    to the USB drive, click on the “Close” button.

    1. Power-off the USB drive by running this command:

        ```nushell
        udisksctl power-off --block-device <path to USB device file>
        ```

    1. Physically remove the USB drive from your system.

1. Make sure that the machine that you’re going to install NixOS on is
powered off.

1. Attach the install medium to the machine that you’re going to install
NixOS on.

1. Start booting into the install medium.

1. At the bootloader menu, choose the option that says “Disko Unattended
NixOS Installer”.

## Instructions for `jason-desktop-linux`

1. Manually install NixOS. When preforming the manual installation, do
not use any of the NixOS configurations from this repository.

    More information about manually installing NixOS can be found in
    [the NixOS manual](https://nixos.org/manual/nixos/stable).

1. After the manual installation is finished, boot into the new NixOS
installation.

1. Switch to using the `jason-desktop-linux` NixOS configuration from
this repository by following [these instructions][1].

[1]: <./How to Switch to a Different Version of This Repository.md>
