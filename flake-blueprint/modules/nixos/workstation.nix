# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
/**
  Common configuration that applies to all workstation machines.

  The configuration in this file does not apply to installation mediums.
*/
{ flake, inputs }:
{ config, pkgs, ... }:
{
  imports = with flake.nixosModules; [
    default
    first-boot
    gui
    home-manager
    neovim
    ssh-server
    syncthing
    vm-guest
  ];

  programs = {
    git = {
      enable = true;
      config = {
        init.defaultBranch = "main";
        user = {
          name = "Jason Yundt";
          email = "jason@jasonyundt.email";
        };
        alias = {
          f = "fetch --all --prune";
          p = "pull --all --prune";
        };
      };
    };
    tmux.enable = true;
    ssh = {
      startAgent = true;
      extraConfig = ''
        AddKeysToAgent yes
      '';
    };
  };
  environment.systemPackages =
    let
      fvpPackages = inputs.forge-view-preview.packages;
    in
    [
      pkgs.chars
      pkgs.elinks
      pkgs.file
      pkgs.man-pages
      pkgs.man-pages-posix
      fvpPackages."${config.nixpkgs.hostPlatform.system}".default
    ];
  documentation = {
    dev.enable = true;
    man.generateCaches = true;
    nixos.includeAllModules = true;
  };
  users.users.jayman = {
    description = "Jason Yundt";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
  security.polkit = {
    # Needed for run0.
    enable = true;
    # This part is based on some code from the ArchWiki [1].
    #
    # [1]: <https://wiki.archlinux.org/title/Polkit#Globally>
    extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (
          subject.isInGroup("wheel")
          && action.id == "org.freedesktop.systemd1.manage-units"
        ) {
          return polkit.Result.AUTH_ADMIN_KEEP;
        }
      });
    '';
  };
}
