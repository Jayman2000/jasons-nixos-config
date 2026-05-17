# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2026 Jason Yundt <jason@jasonyundt.email>
{
  description = "An implementation of lib.unshareableFilesExpression produces nothing";
  outputs =
    { self }:
    {
      lib.unshareableFilesExpression = ./unshareable-files.nix;
    };
}
