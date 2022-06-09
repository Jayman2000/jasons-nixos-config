<!--
SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2021–2022)
-->

# Jason’s [NixOS] Config

This repo will eventually hold the configuration files for my NixOS installs.

## Installation

Follow the instructions in [NixOS’s Installation Instructions](https://nixos.org/manual/nixos/stable/index.html#ch-installation).
Each section in that manual is given a number like 1, 2.2 or 2.2.1. Bellow is a
list of section numbers and any additional notes that I have for them:

- (2.1) Make sure that you boot into UEFI mode.
	Once you’re at a command prompt, run
	[this command](https://askubuntu.com/a/162896):

		[ -d /sys/firmware/efi ] && echo UEFI || echo BIOS

	If it outputs “UEFI”, then you’re good.

- (2.2.3) Use the following labels:
	- `nixos-root` for the root partition.
	- `nixos-swap` for the swap partition.
	- `nixos-hdd` for the data partition on the hard drive.

## Hints for Contributors

If you decide to contribute to this project, then I hope that you’ll find the
following hints helpful:

- Use tabs for indentation. The only exception to this rule is in YAML files
because [YAML requires spaces for
indentation](https://yaml.org/spec/1.2.2/#61-indentation-spaces). In YAML files,
use 4 spaces for indentation.
- You can use [pre-commit](https://pre-commit.com/) to automatically check your
contributions. Follow [these instructions](https://pre-commit.com/#quick-start)
to get started. Skip [the part about creating a pre-commit
configuration](https://pre-commit.com/#2-add-a-pre-commit-configuration).
- Sometimes, it’s OK if a file doesn’t fully pass all of pre-commit’s checks. In
those cases,
[skip the failing hook(s)](https://pre-commit.com/#temporarily-disabling-hooks).

## Copying

See [COPYING.md](./COPYING.md).

[NixOS]: https://nixos.org/
