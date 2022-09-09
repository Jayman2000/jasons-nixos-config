# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
{
	# When the system is using a lot of swap, stopping .swap units can take
	# a while. And yes, DefaultTimeout**START**Sec= controls the **STOP**
	# time for swap units.
	systemd.extraConfig = "DefaultTimeoutStartSec=1800";  # 30 minutes
}
