# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
{ pkgs, ... }:
{
  environment.systemPackages =
    let
      overrideAttrsFunc = finalAttrs: previousAttrs: {
        mesonFlags = (previousAttrs.mesonFlags or [ ]) ++ [
          "-Ddo_userdirs=enabled"
        ];
      };
      # TODO: This override won’t be necessary once we switch to a
      # version of Nixpkgs that has this pull request [1] merged into
      # it.
      #
      # [1]: <https://github.com/NixOS/nixpkgs/pull/430140>
      customVkquake = pkgs.vkquake.overrideAttrs overrideAttrsFunc;
    in
    [ customVkquake ];
  networking.firewall =
    let
      # editorconfig-checker-disable
      # See <https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xhtml?search=26000>.
      # editorconfig-checker-enable
      portListForQuake = [ 26000 ];
    in
    {
      allowedTCPPorts = portListForQuake;
      allowedUDPPorts = portListForQuake;
    };
}
