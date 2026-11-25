# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2026 Jason Yundt <jason@jasonyundt.email>
{
  inputs,
  pkgs,
  pname,
}@args:
let
  originalPkgs = args.pkgs;
  pkgs = originalPkgs.pkgsCross.x86_64-windows;
in
pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
  inherit pname;
  version = "5.0.4";

  src = pkgs.fetchzip {
    url = inputs.jasons-nix-flake-style-guide.lib.buildURI-reference {
      scheme = "https";
      host = "github.com";
      path = [
        ""
        "ShizCalev"
        "MGSHDFix"
        "releases"
        "download"
        finalAttrs.version
        "MGSHDFix_${finalAttrs.version}.zip"
      ];
    };
    stripRoot = false;
    # Remove an unneeded directory.
    postFetch = ''
      rm --recursive -- "$out/logs"
    '';
    hash = "sha256-1ila2mVjV3EEJVshYoROzqBjnPkIYXPEeTH+Kfws8HU=";
  };

  dontUnpack = true;
  buildPhase = ''
    runHook preBuild

    cp --recursive -- "$src" "$out"

    runHook postBuild
  '';

  passthru = {
    updateScript = originalPkgs.nix-update-script {
      extraArgs = [ "--flake" ];
    };
    dllOverrides = {
      wininet = "n,b";
      winhttp = "n,b";
    };
    tests.check-if-dll-overrides-need-updating =
      pkgs.runCommand "check-if-dll-overrides-need-updating"
        {
          inherit (finalAttrs) src;
          nativeBuildInputs = [ pkgs.python3 ];
          readmePath = "${finalAttrs.src}/plugins/MGSHDFix_README.md";
          textToLookFor = ''
            - Open up the game properties of either MGS2/MGS3 in Steam and add the following line to the launch options:

                  WINEDLLOVERRIDES="wininet,winhttp=n,b" %command%
          '';
        }
        ''
          # I tried writing this in Bash, but I couldn’t figure out how to do
          # something like “grep -F” but with fixed strings.
          python -c '
            import os
            import pathlib
            import sys

            readme_path = pathlib.Path(os.environ["readmePath"])
            text_to_look_for = os.environ["textToLookFor"]

            readme_contents = readme_path.read_text(encoding="utf_8")

            if text_to_look_for in readme_contents:
              with pathlib.Path(os.environ["out"]).open(mode="w", encoding="utf_8") as file:
                file.write("Expected text successfully found.\n")
            else:
              print(
                f"ERROR: We expected that the file {readme_path!r} would contain this",
                f"text:\n\n{bytes_to_look_for!r}\n\nIt did not actually contain that text.",
                file=sys.stderr
              )
              sys.exit(1)
          '
        '';
  };

  meta = {
    license = pkgs.lib.licenses.mit;
    sourceProvenance = pkgs.lib.sourceTypes.binaryNativeCode;
  };
})
