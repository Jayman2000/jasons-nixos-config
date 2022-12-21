<!--
SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2021–2022)
-->

# Jason’s [NixOS] Config

How to install and configure NixOS the way I do.

**Note:** At the moment, this repo only work with NixOS 22.05. In the future,
it will be updated to work properly with NixOS 22.11.

## Build a copy of the NixOS 22.05 Manual

Since this repo only works with NixOS 22.05, it’s probably a good idea to follow
the installation instructions in the NixOS 22.05 Manual (as opposed to the
instructions in the manual for the latest version of NixOS). Unfortunately, the
NixOS project doesn’t seem to distribute manuals for older stable versions of
NixOS, so we’ll have to build the NixOS 22.05 Manual from source. Here’s how:

1. Make sure that you have [the Nix package
manager](https://nixos.org/manual/nix/stable/) installed.
	You can verify whether or not Nix is installed by running:

		nix-build --version && \
			echo nix-build is installed. || \
			echo nix-build is not installed.

2. If you don’t already have one, get a local copy of
[the Nixpkgs repo](https://github.com/NixOS/nixpkgs):

		git clone https://github.com/NixOS/nixpkgs.git

3. Change directory into the Nixpkgs repo:

		cd nixpkgs

4. Make sure that you’re looking at the branch that contains the 22.05 version
of the manual:

		git checkout release-22.05

5. Follow the instructions in
`nixos/doc/manual/contributing-to-this-manual.chapter.md`

## Installation

Follow the instructions in NixOS’s Installation Instructions (there’re in the
NixOS 22.05 Manual). Each section in that manual is given a number like 1, 2.2
or 2.2.1. Bellow is a list of section numbers and any additional notes that I
have for them:

- (1) Download the minimal ISO image. Also download its SHA-256 file, but
download it from a separate Tor Browser session. **Make sure that you download
a 22.05 image** (as opposed to one for a later version).

- (2)
	- If you’re installing NixOS on `jasonyundt.website.home.arpa`, then
	create a VM. Its specs should match [the specs of Vultr’s $3.50 per
	month “Regular Performance”
	VM](https://www.vultr.com/pricing/#cloud-compute). Don’t forget to
	make it a UEFI system and not a BIOS one.

	- If you’re installing NixOS on `Graphical-Test-VM`, then make sure that
	the virtual disk you create for it is large enough to store the “Keep
	Across Linux Distros!” Syncthing folder.

- (2.1) Make sure that you boot into UEFI mode.
	Once you’re at a command prompt, run
	[this command](https://askubuntu.com/a/162896):

		[ -d /sys/firmware/efi ] && echo UEFI || echo BIOS

	If it outputs “UEFI”, then you’re good.

- (2.2.1) Give `jasonyundt.website.home.arpa` 2GiB of swap. This is a pretty
arbitrary number.

- (2.2.3) Use the following labels:
	- `nixos-root` for the root partition.
	- `nixos-swap` for the swap partition.
	- `nixos-hdd` for the data partition on the hard drive.

## Post-installation

1. Get a copy of this repo on the machine.
2. In `deployment/home-manager.nix`, make sure that the version number in the
tarball’s URL matches the version of NixOS you installed.
3. In `configuration.nix`, one of the system specific configs:
	- `./deployment/jason-desktop-linux.nix`,
	- `./deployment/jason-laptop-linux.nix`,
	- `./deployment/graphical-test-vm.nix`,
	- `./deployment/jasonyundt.website.nix` or
	- `./deployment/jasonyundt.website.home.arpa.nix`
4. Run `./deploy.sh`.
5. Reboot.
6. Log in as root and set jayman’s password.

### Instructions specific to Jason’s Web Site

These post-installation steps should only be done on `jasonyundt.website` or
`jasonyundt.website.home.arpa`.

1. If one doesn’t already exist, create a new email address on
`jasonyundt.email`. The address should be `<fqdn>@jasonyundt.email` where
`<fqdn>` is the domain name of the machine you’re currently setting up.
2. On the machine that you’re setting up, create a `~root/mail-password` file
that contains the password for that email address.
3. Make sure that only root has access to that file:

		sudo chmod 400 ~root/mail-password

### Instructions specific to graphical installs

These post-installation steps should only be done on graphical systems.

1. Log in via SDDM.
2. Use KGpg to create a new GPG key to use for a KDE Wallet. Make sure that you
save a revocation key.
3. Back up the revocation key in the KeePass database. The other parts of the
key aren’t really needed since this key is only going to be used locally on
one machine.
4. Use KWalletManager to create a new wallet named “default” that uses the
GPG key. If there was an existing wallet before you created this one, delete
that wallet.
5. In KDE Wallet settings, make sure that the new wallet is the default wallet
and that the wallet is closed automatically after 10 minutes.
6. In KWalletManager, add a password entry named “jason@jasonyundt.email”.
7. Import Keyboard shortcuts.kksrc. Go to System
Settings>Workspace>Shortcuts>Shortcuts>Import Scheme…
8. Customize the rest of the system settings.
9. In Firefox, install the following extensions:
	- Plasma Browser integration
	- uBlock Origin
10. In Firefox, enable HTTPS only mode.
11. In Tor Browser Launcher Settings, check “Download over system Tor” and
click “Save & Exit”.
12. In the Tor Browser, enable HTTPS only mode.
13. In the Tor Browser, install uBlock Origin.
14. Set up any additional email accounts in Thunderbird.
15. In Kalendar, set up a reminder on the first of every month to review
installed packages.

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
