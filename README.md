<!--
SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2021–2022)
-->

# Jason’s [NixOS] Config

How to install and configure NixOS the way I do.

## How To Set Up a System That Uses This Config

### 1. Determine what version of NixOS the config currently expects

You must make sure that you install the appropriate version of NixOS. Each
machine’s config is designed to work with only one version of NixOS.

1. Find the machine-specific config file that contains the information that
we’re looking for.
	- For Jason-Desktop-Linux, this is
	`./imports/jason-desktop-linux.nix`.

	- For Jason-Laptop-Linux, this is
	`./imports/jason-laptop-linux.nix`.

	- For Graphical-Test-VM, this is
	`./imports/graphical-test-vm.nix`.

	- For `jasonyundt.website` and `jasonyundt.website.home.arpa`, this is
	`./imports/jasonyundt.website-common.nix`.
2. Open that file.
3. Look for a line that looks like this:

		./home-manager/<version>.nix

You’ll need to install whatever version of NixOS matches that Home Manager
version. If `<version>` is “22.11” then install NixOS 22.11; If `<version>` is
“23.05” then install NixOS 23.05; If `<version>` is “unstable” then install
NixOS Unstable; etc.

### 2. If you plan to install NixOS 22.11, then build its manual

If you’re going to install NixOS 22.11, it’s probably a good idea to follow the
installation instructions in the NixOS 22.11 Manual (as opposed to the
instructions in the manual for the latest version of NixOS). Unfortunately, the
NixOS project isn’t currently distributing built versions of the NixOS 22.11
manual, so we’ll have to build the NixOS 22.11 Manual from source. Here’s how:

1. Make sure that you have [the Nix package
manager](https://nixos.org/manual/nix/stable/) installed.
	You can verify whether or not Nix is installed by running:

		nix-build --version && \
			echo Nix is installed. || \
			echo Nix is not installed.

2. If you don’t already have one, get a local copy of
[the Nixpkgs repo](https://github.com/NixOS/nixpkgs):

		git clone https://github.com/NixOS/nixpkgs.git

3. Change directory into the Nixpkgs repo:

		cd nixpkgs

4. Make sure that you’re looking at the branch that contains the 22.11 version
of the manual:

		git checkout release-22.11

5. Follow the instructions in
`nixos/doc/manual/contributing-to-this-manual.chapter.md`

### 3. Install NixOS

Follow NixOS’s Installation Instructions (there’re in the NixOS Manual). Each
section in that manual is given a number like 1, 2.2 or 2.2.1. Bellow is a list
of section numbers and any additional notes that I have for them:

- (1)

	- Download the minimal ISO image. Also download its SHA-256
	file, but download it from a separate Tor Browser session.
	**Make sure that you download an image for the correct version
	of NixOS** (the version that the machine-specific config
	depends on).

	- Verify the integrity of the installation image:

		1. Make sure that both the `.iso` file and the
		`.iso.sha256` are in the same directory.

		2. Change into that directory.

		3. Run

				sha255sum -c <path-to-sha256-file>

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

- (2.2) Skip right to 2.3. We’re going to be doing a manual
installation, not a graphical one.

- (2.3.2)

	- If you’re going to repartition an entire disk, then before you
	start doing that, delete any existing signatures on the disk:

			wipefs -a <path-to-block-device>

	- Give `jasonyundt.website.home.arpa` 2GiB of swap. This is a pretty
	arbitrary number.

	- Use the following labels:

		- `nixos-root` for the root partition.
		- `nixos-swap` for the swap partition.
		- `nixos-hdd` for the data partition on the hard drive.

### 4. Deploy this config

1. Get a copy of this repo on the machine.
2. In `configuration.nix`, import one of the system specific configs:
	- `./imports/jason-desktop-linux.nix`,
	- `./imports/jason-laptop-linux.nix`,
	- `./imports/graphical-test-vm.nix`,
	- `./imports/jasonyundt.website.nix` or
	- `./imports/jasonyundt.website.home.arpa.nix`
3. Run `./deploy.sh`.
4. Reboot.
5. Log in as root and set jayman’s password.

### 5. Do any manual set up

While it would be nice if this config automatically set up everything
for you, there are some things that need to be set up manually at the
moment.

#### Instructions specific to systems that import `auto-upgrade.nix`

These post-installation steps should only be done on

- `jasonyundt.website`
- `jasonyundt.website.home.arpa`
- `mailserver.test.jasonyundt.email`

1. If one doesn’t already exist, create a new email address on
`jasonyundt.email`. The address should be `<fqdn>@jasonyundt.email` where
`<fqdn>` is the domain name of the machine you’re currently setting up
(don’t include the trailing `.` that represents the root DNS zone).
2. On the machine that you’re setting up, create a `~root/mail-password` file
that contains the password for that email address.
3. Make sure that only root has access to that file:

		sudo chmod 400 ~root/mail-password

##### Instructions specific to `mailserver.test.jasonyundt.email`

This section should only be followed if you’re setting up
`mailserver.test.jasonyundt.email`.

Make sure that the name server(s) for `jasonyundt.email.` have the
following resource records:

```zone
test 10800 IN NS mailserver.test.jasonyundt.email.
mailserver.test 10800 IN A <the machine’s IPv4 address>
mailserver.test 10800 IN AAAA <the machine’s IPv6 address>
```

#### Instructions specific to graphical installs

These post-installation steps should only be done on graphical systems.

1. Log in via SDDM.
2. Use KGpg to create a new GPG key to use for a KDE Wallet.
	1. Start KGpg if it’s not already running.
	2. Right click on the KGpg tray icon.
	3. Click “Key Manager”.
	4. In the menu bar, open Keys > Generate Key Pair…
	5. Click “Expert Mode”.
	6. Answer the prompts in the terminal window.
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
8. Add Transmission and Yakuake to the list of autostart applications.
9. Customize the rest of the system settings.
10. In Firefox, install the following extensions:
	- Plasma Browser integration
	- uBlock Origin
11. In Firefox, enable HTTPS only mode.
12. In Tor Browser Launcher Settings, check “Download over system Tor” and
click “Save & Exit”.
13. In the Tor Browser, enable HTTPS only mode.
14. In the Tor Browser, install uBlock Origin.
15. Set up any additional email accounts in Thunderbird.
16. In Kalendar, set up a reminder on the first of every month to review
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
[this image]: https://en.wikipedia.org/wiki/Domain_Name_System#/media/File:Domain_name_space.svg
