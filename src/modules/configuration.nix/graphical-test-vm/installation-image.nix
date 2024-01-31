# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
{
	imports = [ ../../installation-image.nix ];
	# We’re using the specialisation option in a creative way here. We not
	# ever going to actually activate this specialisation. Instead, we’re
	# declaring it here to make the system’s configuration get prebuilt and
	# added to its installation image’s Nix store. That way we won’t have
	# to wait for the configuration to build when nixos-install gets run.
	specialisation.configToDeploy = {
		inheritParentConfig = false;
		configuration = import ./.;
	};
}
