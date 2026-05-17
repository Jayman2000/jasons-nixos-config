# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2026 Jason Yundt <jason@jasonyundt.email>
{
  inputs,
  pkgs,
  pname,
}:
let
   package = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
     name = pname;

     phases = [ "buildPhase" ];

     __structuredAttrs = true;
     unshareableFilesList = pkgs.callPackage inputs.unshareable.lib.unshareableFilesExpression { };
     unshareableFilesNamesList = pkgs.lib.lists.map (package: package.name) finalAttrs.unshareableFilesList;
     buildPhase = ''
       mkdir -- "$out"
       for i in "''${!unshareableFilesList[@]}"
       do
         path="''${unshareableFilesList["$i"]}"
         name="''${unshareableFilesNamesList["$i"]}"
         ln --symbolic -- "$path" "$out/$name"
       done
     '';
   });
in
# Using pkgs.emptyDirectory here helps us avoid wasting time building this
# package in situations where we know that building this package would result
# in an empty directory.
if (pkgs.lib.lists.length package.unshareableFilesList) == 0 then pkgs.emptyDirectory else package
