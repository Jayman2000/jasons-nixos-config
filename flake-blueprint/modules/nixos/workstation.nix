# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025–2026 Jason Yundt <jason@jasonyundt.email>
/**
  Common configuration that applies to all workstation machines.

  The configuration in this file does not apply to installation mediums.
*/
{ flake, inputs }:
{
  config,
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [
    # This first one was suggested by nixos-generate-config. Without it,
    # I wasn’t able to connect to Wi-Fi networks on jasons-lemur-pro.
    (modulesPath + "/installer/scan/not-detected.nix")
    flake.nixosModules.default
    flake.nixosModules.first-boot
    flake.nixosModules.gui
    flake.nixosModules.home-manager
    flake.nixosModules.media
    flake.nixosModules.neovim
    flake.nixosModules.ssh
    flake.nixosModules.syncthing
    flake.nixosModules.vm-guest
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
        # This allows me to push to Git remotes that are stored in
        # Syncthing folders.
        safe.directory = "*";

        sendemail = {
          smtpServer = "box.jasonyundt.email";
          smtpUser = "jason@jasonyundt.email";
          # Weirdly enough, setting smtpEncryption to "ssl" does not mean “use
          # SSL”. Instead it means “implicitly use TLS. If smtpServerPort is
          # not specified, then use the standard port for implicit TLS: port
          # 465.”
          #
          # Source: <man:git-send-email(1)>
          smtpEncryption = "ssl";
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
    virt-manager.enable = true;
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
      pkgs.redumper
      pkgs.unar
      pkgs.libreoffice-qt6-fresh
      # These next few packages make spellchecking work in LibreOffice. Source:
      # <https://wiki.nixos.org/wiki/LibreOffice>.
      pkgs.hunspell
      pkgs.hunspellDicts.en_US
      pkgs.hyphenDicts.en_US

      pkgs.cifs-utils
      pkgs.forgejo-cli
      pkgs.gimp
      pkgs.inkscape
      fvpPackages."${config.nixpkgs.hostPlatform.system}".default
    ];
  documentation = {
    dev.enable = true;
    man.cache.enable = true;
    nixos.includeAllModules = true;
  };
  users.users.jayman = {
    description = "Jason Yundt";
    isNormalUser = true;
    extraGroups = [
      # This allows jayman to use sudo and run0.
      "wheel"
      # This allows jayman to mess with NetworkManager. See
      # <https://wiki.nixos.org/wiki/NetworkManager#Installation>.
      "networkmanager"
    ];
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
  virtualisation = {
    docker.rootless = {
      enable = true;
      setSocketVariable = true;
    };
    libvirtd.enable = true;
  };
  # This allows me to use Cloudflare WARP. Cloudflare WARP allows me to
  # circumvent restrictions when connected to certain Wi-Fi networks.
  services.cloudflare-warp.enable = true;
}
