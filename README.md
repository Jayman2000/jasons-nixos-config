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

## Post-installation

1. Get a copy of this repo on the machine.
2. In `deployment/home-manager.nix`, make sure that the version number in the
tarball’s URL matches the version of NixOS you installed.
3. In `configuration.nix`, import the following:
	- `./deployment/home-manager.nix`
	- `./deployment/common.nix`
	- `./deployment/jason-laptop-linux.nix`
4. In `./deployment/common.nix`, make sure that `home.stateversion` matches the
version of NixOS you installed.
5. Run `./deploy.sh`.
6. Reboot.
7. Once the display manager starts, switch to a TTY and set jayman’s password.
8. Log in via SDDM.
9. Use KGpg to create a new GPG key to use for a KDE Wallet. Make sure that you
save a revocation key.
10. Back up the revocation key in the KeePass database. The other parts of the
key aren’t really needed since this key is only going to be used locally on
one machine.
11. Use KWalletManager to create a new wallet named “default” that uses the
GPG key. If there was an existing wallet before you created this one, delete
that wallet.
12. In KDE Wallet settings, make sure that the new wallet is the default wallet
and that the wallet is closed automatically after 10 minutes.
13. In KWalletManager, add a password entry named “jason@jasonyundt.email”.
14. Import Keyboard shortcuts.kksrc. Go to System
Settings>Workspace>Shortcuts>Shortcuts>Import Scheme…
15. Customize the rest of the system settings.
16. In Firefox, install the following extensions:
	- Plasma Browser integration
	- uBlock Origin
17. In Firefox, enable HTTPS only mode.
18. In Tor Browser Launcher Settings, check “Download over system Tor” and
click “Save & Exit”.
19. In the Tor Browser, enable HTTPS only mode.
20. In the Tor Browser, install uBlock Origin.
21. Set up any additional email accounts in Thunderbird.

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
