<!--
SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2021–2024)
-->

# 5. Do the installation

First decide whether you’re going to do a manual installation or an unattended
installation:

- If you’re installing NixOS on Jason-Desktop-Linux, then you must do a manual
installation.

- If you’re installing NixOS on Graphical-Test-VM or
`jasonyundt.website.home.arpa`, then you can do a manual installation or an
unattended installation.

If you can do an unattended installation, then it’s strongly recommended that
you do do an unattended installation. It’s much less error prone. It’s also
easier.

## Manual installation

Follow NixOS’s Installation Instructions (there’re in the NixOS Manual). Each
section in that manual is given a name like “Installation”, “Obtaining NixOS”
or “Installing NixOS”. Bellow is a list of section names and any additional
notes that I have for them:

- Obtaining NixOS: You don’t need to obtain a NixOS installation image. Instead,
you can just boot into [the JNC install drive](./Step%204.md). If you’re
installing NixOS on a physical system, then this is the USB drive that you
created earlier. If you’re installing NixOS on a virtual machine, then this is
the `vm-install-drive.img` file that you created earlier.

- Installing NixOS:
	- If you’re installing NixOS on `jasonyundt.website.home.arpa`, then
	create a VM. Its specs should match [the specs of Vultr’s $3.50 per
	month “Regular Performance”
	VM](https://www.vultr.com/pricing/#cloud-compute). Don’t forget to
	make it a UEFI system and not a BIOS one.

	- If you’re installing NixOS on `Graphical-Test-VM`, then make sure that
	the virtual disk you create for it is large enough to store the “Keep
	Across Linux Distros!” Syncthing folder.

- Graphical Installation: Skip right to the Manual Installation section. We’re
going to be doing a manual installation, not a graphical one.

- Partitioning and formatting:

	- If the machine that you’re installing NixOS on uses
	[Disko](https://github.com/nix-community/disko), then skip this step (go
	right to the step labeled “Installing”). Here’s how you determine if the
	machine that you’re using uses Disko:

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

		- If you’re installing NixOS on Jason-Desktop-Linux, then you’ll
		need to create several partitions with specific partition types.
		Once you’ve taken a look at the table on [this page], create the
		following parations:

			- On the NVME SSD, create two partitions:

				- The first one should be an EFI System
				Partition. Name it “EFI system partition”.

				- The second one should be a Generic Linux Data
				Partition. Name it “NixOS SSD Partition”.

			- On the first Western Digital HDD, create a Generic
			Linux Data Partition. Name it “NixOS HDD 1 Partition”.

			- On the second Western Digital HDD, create a Generic
			Linux Data Partition. Name it “NixOS HDD 2 Partition”.

	- (Formatting): If you’re install NixOS on Jason-Desktop-Linux, then run
	these commands to create a bcachefs root partition:

		```bash
		SSD=/dev/disk/by-partlabel/NixOS\\x20SSD\\x20Partition
		HDD1=/dev/disk/by-partlabel/NixOS\\x20HDD\\x201\\x20Partition
		HDD2=/dev/disk/by-partlabel/NixOS\\x20HDD\\x202\\x20Partition

		bcachefs format \
			--replicas=2 \
			--label=SSD "$SSD" \
			--label=HDD.HDD1 "$HDD1" \
			--label=HDD.HDD2 "$HDD2" \
			--foreground_target=SSD \
			--promote_target=SSD \
			--background_target=HDD
		```

- Installing:

	1. If the machine uses Disko, then skip this step. If you’re installing
	on Jason-Desktop-Linux, then here’s how you mount the root filesystem:

		```bash
		SSD=/dev/disk/by-partlabel/NixOS\\x20SSD\\x20Partition
		HDD1=/dev/disk/by-partlabel/NixOS\\x20HDD\\x201\\x20Partition
		HDD2=/dev/disk/by-partlabel/NixOS\\x20HDD\\x202\\x20Partition

		mount "$SSD:$HDD1:$HDD2" /mnt
		```

	2. If the machine uses Disko, then skip this step.

	3. If the machine uses Disko, then skip this step.

	4. Always skip this step. In the next step, `install-using-jnc`
	will automatically generate a config for us.

	5. Don’t run `nixos-install` directly. Instead, run `install-using-jnc`.

[this page]: https://uapi-group.org/specifications/specs/discoverable_partitions_specification/#defined-partition-type-uuids

## Unattended installation

1. Start booting [the JNC install drive](./Step%204.md). If you’re installing
NixOS on a physical system, then this is the USB drive that you created earlier.
If you’re installing NixOS on a virtual machine, then this is the
`vm-install-drive.img` file that you created earlier.

2. At the [systemd-boot](https://systemd.io/BOOT) menu, select the option
labeled “unattendedInstall”.

---

[Previous step](./Step%204.md) [Next step](./Step%206.md)
