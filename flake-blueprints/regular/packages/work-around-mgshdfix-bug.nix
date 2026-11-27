# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2026 Jason Yundt <jason@jasonyundt.email>
{ pkgs, pname }:
/**
  Script that works around an MGSHDFix bug

  If we ever switch to a version of MGSHDFix that does not have [this
  bug](https://github.com/ShizCalev/MGSHDFix/issues/460), then this package
  should be removed.
*/
pkgs.resholve.writeScriptBin pname
  {
    interpreter = pkgs.lib.meta.getExe pkgs.bash;
    inputs = [ pkgs.coreutils ];
  }
  ''
    # See <https://steamdb.info/app/2131680>.
    readonly mg_and_mg2_steam_release_date=2023-10-24T08:07:00Z

    touch --no-create --date="$mg_and_mg2_steam_release_date" winhttp.dll wininet.dll
  ''
