<!--
SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
-->

# 3. Potentially create a temporary installation of NixOS

In a previous step, you determined what version of NixOS was going to be
installed. Unfortunately, you’re going to need to already have a system that’s
running that version of NixOS. If you do not already have a system that’s
running that version of NixOS, then you’ll need to create a temporary
installation of NixOS before you continue. Please follow the installation
instructions in the NixOS manual in order to create that installation of NixOS.

In a previous step, you may have built a manual for an older version of NixOS.
In that case, you should use the manual that you built. Otherwise, you can find
a copy of the NixOS manual on [NixOS’s Web site](https://nixos.org).

Please note that if you already have a working installation of the correct
version of NixOS, then this step is totally optional. In other words, if you’re
going to install NixOS 23.11 and you already have a machine that runs NixOS
23.11, then you can just use that machine.

No matter which machine you use, you need to make sure that a few NixOS options
are set correctly:

```nix
{ pkgs, ... }:
{
	boot = {
		supportedFilesystems = [ "bcachefs" ];
		# This part won’t be needed once NixOS’s default version of the
		# Linux kernel supports bcachefs.
		kernelPackages = pkgs.linuxPackages_latest;
	};
	services.udisks2.enable = true;
}
```

---

[Previous step](./Step%202.md) [Next step](./Step%204.md)
