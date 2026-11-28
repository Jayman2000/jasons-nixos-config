# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025–2026 Jason Yundt <jason@jasonyundt.email>
{ pkgs, pname }:
# TODO: Open an upstream feature request for Linux support.
let
  dotnetPackages = pkgs.dotnetCorePackages.dotnet_10;
in
pkgs.buildDotnetModule (finalAttrs: {
  inherit pname;
  version = "1.1.1";
  # TODO: Add update script.
  # TODO: Test update script.

  src = pkgs.fetchFromGitHub {
    owner = "vadimtrifonov";
    repo = "nexusmods-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mYeFyxaCNqXJdENLzjSWl6W0ejyeU4Y1aU8y4PfJY9w=";
  };

  projectFile = "src/NexusMods/NexusMods.csproj";
  dotnet-sdk = dotnetPackages.sdk;
  dotnet-runtime = dotnetPackages.runtime;

  # TODO: If this works, add a citation to nexusmods-cli’s source code.
  preConfigure = ''
    dotnet restore nexusmods-cli.slnx --locked-mode
  '';

  # TODO: meta.sourceProvenence
  # TODO: meta.license
})
