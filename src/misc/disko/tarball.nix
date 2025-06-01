# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024–2025)
{ lib ? null, customLib ? import ../../lib.nix { inherit lib; } }:
customLib.fetchFromGitHubOptionalHash {
	owner = "nix-community";
	repo = "disko";
	rev = "v1.12.0";
	sha256 = "0wbx518d2x54yn4xh98cgm65wvj0gpy6nia6ra7ns4j63hx14fkq";
}
