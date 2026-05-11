# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
{
  pkgs,
  pname,
  system,
}:
let
  originalPackage = pkgs."${pname}";
  inherit (pkgs.lib.attrsets) filterAttrs;
  # The i686-linux version of this test fails to evaluate. We’re
  # excluding it in order to make sure that there aren’t any evaluation
  # errors.
  filterAttrsFunction = name: value: name != "simpleUefiSystemdBoot";
  overrideFunction = final: prev: {
    passthru = prev.passthru // {
      tests = filterAttrs filterAttrsFunction prev.passthru.tests;
    };
  };
  overriddenPackage = originalPackage.overrideAttrs overrideFunction;
in
if system == "i686-linux" then overriddenPackage else originalPackage
