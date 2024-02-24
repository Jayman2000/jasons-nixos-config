# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
#
# Normally, I would use an imports list [1], but the disko command
# doesn’t actually pay attention to the imports list, so I have to use
# the import function [2].
#
# [1]: <https://nixos.org/manual/nixos/stable#sec-modularity>
# [2]: <https://nixos.org/manual/nix/stable/language/builtins#builtins-import>
import ../../misc/disko/base-configuration.nix {
	swapSize = "2G";
}
