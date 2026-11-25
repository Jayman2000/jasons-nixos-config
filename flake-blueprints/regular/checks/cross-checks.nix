# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2026 Jason Yundt <jason@jasonyundt.email>
{
  flake,
  pkgs,
  pname,
  system,
  ...
}:
/**
  A check that depends on all checks in `flake.crossOutputs`.

  If this check builds successfully, then that means that all of the checks in
  `flake.crossOutputs` have already been built successfully.
*/
pkgs.runCommand pname
  {
    __structuredAttrs = true;
    crossChecks =
      let
        inherit (pkgs.lib.attrsets) attrValues;
        allCrossOutputSets = attrValues flake.crossOutputs;
        crossOutputSetToCurrentSystemChecks =
          crossOutputSet: attrValues ((crossOutputSet.checks or { })."${system}" or { });
        crossChecksThatBuildOnCurrentSystem = pkgs.lib.lists.concatMap (crossOutputSetToCurrentSystemChecks) allCrossOutputSets;
      in
      crossChecksThatBuildOnCurrentSystem;
  }
  ''
    declare -p crossChecks
    mkdir -- "$out"
    for i in "''${!crossChecks[@]}"
    do
      ln --symbolic -- "''${crossChecks["$i"]}" "$out/$i"
    done
  ''
