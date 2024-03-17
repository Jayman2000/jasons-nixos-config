<!--
SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2021–2024)
-->

# 4. Create a JNC install drive

You’ll need to do the following on a machine that’s running an appropriate
version of NixOS (see [this previous step](./Step%203.md).):

1. Make sure that you have a local copy of this repository.

2. Change directory into that local copy of this repository:

	```bash
	cd <path-to-jasons-nixos-config>
	```

3. Attach a really large block device to your system, and determine its path:

	Unfortunately, creating an install drive requires a lot of free space.
	Specifically, install drives for `jasonyundt.website.home.arpa` require
	about 40GiB of free space, and install drives for the other systems
	require about 110GiB of free space.

	If you’re installing NixOS on a physical system, then:

	1. Find a USB drive that’s large enough.

	2. Connect it to your system.

	3. Take note of the path to its block device.

	If you’re install NixOS on a virtual machine, then:

	1. Create a file that’s large enough to hold the install drive:

		```bash
		nix-shell -p util-linux --run '
			fallocate --length <number>GiB vm-install-drive.img
		'
		```

	2. Turn that file into a loop device:

		```bash
		udisksctl loop-setup --file vm-install-drive.img
		```

		When that command finishes successfully, it will tell you the
		path to the block device that it created. Take note of that
		path.

4. Determine the machine slug for the machine that you’re going to be installing
NixOS on:

	- Jason-Desktop-Linux’s machine slug is `jason-desktop-linux`

	- Graphical-Test-VM’s machine slug is `graphical-test-vm`

	- `jasonyundt.website.home.arpa`’s machine slug is
	`jasonyundt.website.home.arpa`

5. Create a JNC install drive:

	```bash
	JNC_INSTALL_DRIVE=<path-to-block-device> JNC_MACHINE_SLUG=<machine-slug> ./create-jnc-install-drive.sh
	```

	When you run this command, it may ask you to enter the passwords for a
	whole bunch of different machines. Feel free to choose whatever
	passwords you want. You don’t have to know what the passwords for these
	machines actually are. You just have to create new ones.

---

[Previous step](./Step%203.md) [Next step](./Step%205.md)
