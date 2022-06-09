# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
{
	boot.loader = {
		systemd-boot = {
			enable = true;
			# Theoretically, this should make the boot loader faster and save disk
			# space, but the effect is probably negligeable.
			configurationLimit = 10;
		};
		efi.canTouchEfiVariables = true;
	};
}
