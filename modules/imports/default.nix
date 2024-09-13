# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2024 Jason Yundt <jason@jasonyundt.email>
{
    imports = let
        isNotDefaultDotNix = name: name != "default.nix";
        directoryListing = builtins.readDir ./.;
        allModules = builtins.attrNames directoryListing;
        otherModules = builtins.filter isNotDefaultDotNix allModules;
        moduleNameToPath = moduleName: ./. + "/${moduleName}";
    in builtins.map moduleNameToPath otherModules;
}
