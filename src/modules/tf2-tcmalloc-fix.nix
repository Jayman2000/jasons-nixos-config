# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022–2023)
{
	# This is part of a workaround for this bug:
	# <https://github.com/ValveSoftware/Source-1-Games/issues/5043>.
	# Once that bug gets fixed, this workaround will no longer be
	# needed.
	nixpkgs.overlays = let
		defaultExtraLibraries = pkgsForExtraLibraries: [ ];
		additionalExtraLibraries = pkgsForExtraLibraries: [
			pkgsForExtraLibraries.gperftools
		];
		steam-fhsenvOverride = {
			extraLibraries ? defaultExtraLibraries,
			...
		}: let
			superExtraLibraries = extraLibraries;
		in {
			extraLibraries = (pkgsForEL:
				(superExtraLibraries pkgsForEL)
				++ (additionalExtraLibraries pkgsForEL)
			);
		};
		steamPackagesOverride = self: super: {
			steam-fhsenv = super.steam-fhsenv.override steam-fhsenvOverride;
		};
		nixpkgsOverlay = self: super: {
			steamPackages = super.steamPackages.overrideScope steamPackagesOverride;
		};
	in [ nixpkgsOverlay ];
}
