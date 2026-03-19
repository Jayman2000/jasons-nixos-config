# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
{ pkgs, pname }:
let
  # editorconfig-checker-disable
  url = "https://upload.wikimedia.org/wikipedia/commons/b/be/Fry_Kid_Perched_on_McDonald%27s_Sign.jpg";
  # editorconfig-checker-enable
in
pkgs.runCommandWith
  {
    name = pname;
    derivationArgs = {
      src = pkgs.fetchurl {
        inherit url;
        hash = "sha256-1YKiHIlBlSsj7STLreliYtjOVZg82sZOAg1wjoNFbyE=";
      };
      nativeBuildInputs = [ pkgs.imagemagick ];
      meta.license = pkgs.lib.licenses.cc-by-sa-40;
    };
  }
  ''
    mkdir -- "$out"
    magick "$src" -crop 100x100+984+596 "$out/image.png"

    # This part adds attribution for the image.
    # See this CC Wiki page [1].
    #
    # editorconfig-checker-disable
    # [1]: <https://wiki.creativecommons.org/wiki/Recommended_practices_for_attribution>
    # editorconfig-checker-enable
    readonly readme="$out/README.md"
    echo \
      "[“Fry Kid Perched on McDonald's Sign.jpg”][1] by" \
      "[RyanStudiesBirds][2] is licensed under" \
      "[🅭🅯🄎4.0][3]. / Cropped from original" \
      > "$readme"
    echo >> "$readme"
    echo \
      "[1]:" ${pkgs.lib.strings.escapeShellArg url} \
      >> "$readme"
    echo \
      "[2]:" https://en.wikipedia.org/wiki/User:RyanStudiesBirds \
      >> "$readme"
    echo \
      "[3]:" https://creativecommons.org/licenses/by-sa/4.0 \
      >> "$readme"
  ''
