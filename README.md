<!--
SPDX-License-Identifier: CC0-1.0
SPDX-FileCopyrightText: 2024 Jason Yundt <jason@jasonyundt.email>
-->

# Jason’s NixOS Config

How to install and configure NixOS the way I do.

## Hints for Contributors

- This repo’s flake provides a dev shell that contains some of the tools
that I use when developing this repo. You can activate the dev shell by
running this command:

    ```bash
    nix \
        --extra-experimental-features nix-command \
        --extra-experimental-features flakes \
        develop \
            '.#pinnedNixVersion' \
            --command \
                nix \
                    --extra-experimental-features nix-command \
                    --extra-experimental-features flakes \
                    develop
    ```

    That command is overly long for two reasons:

    1. It’s designed to work even if you don’t have any experimental
    features enabled.
    2. It tried to pin the version of Nix that gets used to evaluate
    `flake.nix`.
- You can use [pre-commit][1] to automatically check your contributions.
Follow [these instructions][2] to get started. Skip [the part about
creating a pre-commit configuration][3].
- Try to keep lines shorter than seventy-three characters.
- This repo uses an [EditorConfig](https://editorconfig.org) file.
- Use [CommonMark](https://commonmark.org) for Markdown files.

[1]: https://pre-commit.com
[2]: https://pre-commit.com/#quick-start
[3]: https://pre-commit.com/#2-add-a-pre-commit-configuration

## Copying

See [`copying.md`](./copying.md).
