<!--
SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2021–2024)
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
	`./src/modules/jason-desktop-linux.nix`.

	- For Graphical-Test-VM, this is
	`./src/modules/graphical-test-vm.nix`.

	- For `jasonyundt.website.home.arpa`, this is
	`./src/modules/jasonyundt.website-common.nix`.
2. Open that file.
3. Look for a line that looks like this:

		./home-manager/<version>.nix

You’ll need to install whatever version of NixOS matches that Home Manager
version. If `<version>` is “22.11” then install NixOS 22.11; If `<version>` is
“23.05” then install NixOS 23.05; If `<version>` is “unstable” then install
NixOS Unstable; etc.

### 2. If you plan to install NixOS 23.05, then build its manual

If you’re going to install NixOS 23.05, it’s probably a good idea to follow the
installation instructions in the NixOS 23.05 Manual (as opposed to the
instructions in the manual for the latest version of NixOS). Unfortunately, the
NixOS project isn’t currently distributing built versions of the NixOS 23.05
manual, so we’ll have to build the NixOS 23.05 Manual from source. Here’s how:

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

4. Make sure that you’re looking at the branch that contains the 23.05 version
of the manual:

		git checkout release-23.05

5. Follow the instructions in
`nixos/doc/manual/contributing-to-this-manual.chapter.md`

### 3. Install NixOS

Follow NixOS’s Installation Instructions (there’re in the NixOS Manual). Each
section in that manual is given a name like “Installation”, “Obtaining NixOS”
or “Installing NixOS”. Bellow is a list of section names and any additional
notes that I have for them:

- Obtaining NixOS: Don’t download an ISO file. Instead, do this:

	1. Change directory to the root of this repo:

		```bash
		cd <path-to-repo>
		```

	2. Determine the machine slug for the machine that you’re going to be
	installing NixOS on:

		- Jason-Desktop-Linux’s machine slug is
		`jason-desktop-linux`

		- Graphical-Test-VM’s machine slug is
		`graphical-test-vm`

		- `jasonyundt.website.home.arpa`’s machine slug is
		`jasonyundt.website.home.arpa`

	3. Build the installation image:

		```bash
		JNC_MACHINE_SLUG=<slug> ./build-iso.sh

	4. When that script finished, there will be an ISO file in the
	`result/iso/` directory.

- Installing NixOS:
	- If you’re installing NixOS on `jasonyundt.website.home.arpa`, then
	create a VM. Its specs should match [the specs of Vultr’s $3.50 per
	month “Regular Performance”
	VM](https://www.vultr.com/pricing/#cloud-compute). Don’t forget to
	make it a UEFI system and not a BIOS one.

	- If you’re installing NixOS on `Graphical-Test-VM`, then make sure that
	the virtual disk you create for it is large enough to store the “Keep
	Across Linux Distros!” Syncthing folder.

	- Before you continue, decide whether or not you’re going to do
	an unattended installation:

		1. Open this repo’s root directory in a file manager.

		2. Determine the machine slug for the machine that
		you’re going to be installing NixOS on:

			- Jason-Desktop-Linux’s machine slug is
			`jason-desktop-linux`

			- Graphical-Test-VM’s machine slug is
			`graphical-test-vm`

			- `jasonyundt.website.home.arpa`’s machine slug is
			`jasonyundt.website.home.arpa`

		3. Look inside the `src/modules/disko/` directory. If
		there’s a file named `<machine-slug>.nix`, then you can
		do an unattended installation if you want to. If there
		isn’t a file named `<machine-slug>.nix`, then you cannot
		do an unattended installation.

- Booting from the install medium:

	- If you’re going to do an unattended installation, then select
	the “Unattended Install” option from the boot menu. Once you
	select that option, the rest of the installation will be done
	for you. Skip directly to “4. Do any manual set up”.

- Graphical Installation: Skip right to the Manual Installation section. We’re
going to be doing a manual installation, not a graphical one.

- Partitioning and formatting:

	- If the machine that you’re installing NixOS on uses
	[Disko](https://github.com/nix-community/disko), then skip this
	step. Here’s how you determine if the machine that you’re using
	uses Disko:

		1. Determine what machine slug this machine uses:

			- Jason-Desktop-Linux’s machine slug is
			`jason-desktop-linux`

			- Graphical-Test-VM’s machine slug is
			`graphical-test-vm`

			- `jasonyundt.website.home.arpa`’s machine slug is
			`jasonyundt.website.home.arpa`

		2. Open `./src/modules/disko`

		3. If there’s a file named `<slug>.nix` then this
		machine uses Disko. If there isn’t a file named
		`<slug>.nix`, then this machine doesn’t use Disko.

	- UEFI (GPT):

		- If you’re going to repartition an entire disk, then
		before you start doing that, delete any existing signatures on
		the disk:

				wipefs -a <path-to-block-device>

		- Give `jasonyundt.website.home.arpa` 2GiB of swap. This
		is a pretty arbitrary number.

		- Use the following labels:

			- `nixos-root` for the root partition.
			- `nixos-swap` for the swap partition.
			- `nixos-hdd` for the data partition on the hard drive.

- Installing:

	1. If the machine uses Disko, then skip this step.

	2. If the machine uses Disko, then skip this step.

	3. If the machine uses Disko, then skip this step.

	4. Always skip this step. In the next step, `install-using-jnc`
	will automatically generate a config for us.

	5. Don’t run `nixos-install` directly. Instead, run `install-using-jnc`.

### 4. Do any manual set up

While it would be nice if this config automatically set up everything
for you, there are some things that need to be set up manually at the
moment.

#### Instructions common to all systems

1. Log in as root and set jayman’s password.

#### Instructions specific to systems that import `auto-upgrade.nix`

These post-installation steps should only be done on
`jasonyundt.website.home.arpa`.

1. If one doesn’t already exist, create a new email address on
`jasonyundt.email`. The address should be `<fqdn>@jasonyundt.email` where
`<fqdn>` is the domain name of the machine you’re currently setting up
(don’t include the trailing `.` that represents the root DNS zone).
2. On the machine that you’re setting up, create a `~root/mail-password` file
that contains the password for that email address.
3. Make sure that only root has access to that file:

		sudo chmod 400 ~root/mail-password

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
6. In KWalletManager, add a password entry named <jason@jasonyundt.email>.
7. Import Keyboard shortcuts.kksrc. Go to System
Settings>Workspace>Shortcuts>Shortcuts>Import Scheme…
8. Add Transmission and Yakuake to the list of autostart applications.
9. Customize the rest of the system settings.
10. In Firefox, install the following extensions:
	- Plasma Browser integration
	- uBlock Origin
11. In Firefox, enable HTTPS only mode.
12. Set up any additional email accounts in Thunderbird.
13. In Kalendar, set up a reminder on the first of every month to review
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
