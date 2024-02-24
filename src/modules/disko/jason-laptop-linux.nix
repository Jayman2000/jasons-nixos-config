# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
#
# See the comment at the top of ./jasonyundt.website.home.arpa.nix.
import ../../misc/disko/base-configuration.nix {
	device = "/dev/disk/by-path/pci-0000:00:1f.2-ata-1";
	swapSize = "8G";
}
