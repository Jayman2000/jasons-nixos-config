# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2024 Jason Yundt <jason@jasonyundt.email>
{ config, lib, pinnedNixVersion, ... }:
{
    options.jnc.commonOptions = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
            Common options for all machines that use Jason’s NixOS
            Config.
        '';
    };
    config = lib.mkIf config.jnc.commonOptions {
        boot.loader.systemd-boot.enable = true;
        nix.package = pinnedNixVersion;
    };
}
