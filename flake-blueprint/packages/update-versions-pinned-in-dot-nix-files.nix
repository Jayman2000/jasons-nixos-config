# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2026 Jason Yundt <jason@jasonyundt.email>
{ pkgs, pname }:
pkgs.resholve.writeScriptBin pname
  {
    interpreter = pkgs.lib.meta.getExe pkgs.bash;
    inputs = [ ];
  }
  ''
    echo Finished updating version numbers that are pinned in .nix files.
  ''
