<!--
SPDX-License-Identifier: CC0-1.0
SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
-->

# How to Switch to a Different Version of This Repository

You might have a system that uses a NixOS configuration that’s declared
in this repository. If you do, then you’ll probably want to switch to
different versions of this repository every so often. For example, you
might want to try a configuration change, or you might want to update
the system.

You can switch that system to a different version of this repository by
following these instructions:

1. Make sure that you have a copy of this repository on the system that
you want to update.

1. Open a terminal.

1. Change directory into the root of the local copy of this repository
by running this command:

    ```nushell
    cd <path to repository>
    ```

1. _(Optional)_ Use a command like `git switch` or `git pull` to change
the contents of the Git repository.

1. Start the default dev shell that by running this command:

    ```nushell
    nix --extra-experimental-features 'nix-command flakes' develop
    ```

1. Get a list of NixOS configurations that this repository provides by
running this command:

    ```nushell
    n eval --apply builtins.attrNames .#nixosConfigurations
    ```

1. Choose which of those configurations you want to use.

1. Store your chosen configuration in a variable by running this
command:

    ```nushell
    let config_attr_name = <name of config that you chose>
    ```

1. Build the configuration by running this command:

    ```nushell
    (
        nr
            $".#nixosConfigurations.($config_attr_name)"
            boot
                --flake $".#($config_attr_name)"
    )
    ```

1. Exit the dev shell by running this command:

    ```nushell
    exit
    ```

1. Reboot.
