# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
{
  config,
  flake,
  inputs,
  lib,
  perSystem,
  pkgs,
  ...
}:
{
  imports = [ flake.nixosModules.default ];

  options.jnc.configToInstallName =
    let
      configNames = builtins.attrNames flake.nixosConfigurations;
      filterFunc = (name: !(lib.strings.hasPrefix "install-" name));
      validChoices = builtins.filter filterFunc configNames;
    in
    lib.options.mkOption {
      type = lib.types.enum validChoices;
      example = builtins.head validChoices;
      description = ''
        The attribute name of the configuration that will be installed.

        This value is used in order to determine what configuration will
        be used when performing an unattended installation.
      '';
    };

  config =
    let
      inherit (config.jnc) configToInstallName;
      configs = flake.nixosConfigurations;
      configToInstall = configs."${configToInstallName}";
    in
    {
      # We’re going to create a fresh new install medium every time we
      # do an install. We’re not going to keep an install medium around
      # for a while and then upgrade it to a newer version of NixOS so
      # we can just use the current NixOS version as the state version.
      system.stateVersion = config.system.nixos.release;

      disko.devices.disk.main = {
        # This gets overridden by either the Disko image generator or
        # disko-install.
        device = "/var/empty";
        type = "disk";
        imageSize = "4G";
        content = {
          type = "gpt";
          # NOTE: It’s important that the partition names here don’t
          # match the partition names for the NixOS system that will be
          # installed. Otherwise, the install drive may fail to boot.
          partitions = {
            # TODO: Potentially start using spaces in partition names,
            # depending on how this issue [1] gets resolved.
            #
            # [1]: <https://github.com/nix-community/disko/issues/1053>
            #"Install Drive ESP" = {
            efiSystemPartiton = {
              # editorconfig-checker-disable
              # Source: <https://uefi.org/specs/UEFI/2.11/05_GUID_Partition_Table_Format.html#defined-gpt-partition-entry-partition-type-guids>
              # editorconfig-checker-enable
              type = "C12A7328-F81F-11D2-BA4B-00A0C93EC93B";
              size = "1G";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            #"Install Drive Root" = {
            installDriveRoot = {
              # editorconfig-checker-disable
              # Source: <https://uapi-group.org/specifications/specs/discoverable_partitions_specification>
              # editorconfig-checker-enable
              type = "4F68BCE3-E8CD-4DB1-96E7-FBCAF984B709";
              size = "100%";
              content = {
                type = "filesystem";
                format = "bcachefs";
                mountpoint = "/";
              };
            };
          };
        };
      };
      # This next part is supposed to prebuild the configuration that’s
      # going to be installed. That way, the configuration will get
      # built on the machine that’s creating the installation medium
      # instead of the machine that’s having NixOS installed on it.
      #
      # editorconfig-checker-disable
      environment.etc.configToInstall.source = "${configToInstall.config.system.build.toplevel}";
      # editorconfig-checker-enable

      systemd = {
        services.unattended-install =
          let
            dependencies = [ "network-online.target" ];
          in
          {
            wants = dependencies;
            after = dependencies;
            unitConfig.SuccessAction = "reboot";
            # This allows me to debug when things go wrong. It also
            # makes it clear that an error has happened.
            onFailure = [ "multi-user.target" ];
            serviceConfig = {
              StandardOutput = "journal+console";
              StandardError = "journal+console";
            };
            path =
              let
                inherit (config.nixpkgs.hostPlatform) system;
                defaultDevShell = flake.devShells."${system}".default;
                # We need at least one of the packages from this
                # devShell in order to avoid getting warnings about
                # potentially not using the pinned version of Nix.
                packages = defaultDevShell.nativeBuildInputs;
              in
              packages
              ++ [
                perSystem.self.disko-install
                # disko-install ends up running the Nix package manager,
                # and the Nix package manager will fail if Git isn’t
                # available.
                pkgs.gitMinimal
                # TODO: This can be removed after this Disko bug [1] is
                # fixed.
                #
                # editorconfig-checker-disable
                # [1]: <https://github.com/nix-community/disko/issues/1064>
                # editorconfig-checker-enable
                pkgs.util-linux
              ];
            script =
              let
                inherit (lib.strings) escapeShellArg;
                jnfsgLib = inputs.jasons-nix-flake-style-guide.lib;
                baseURL = jnfsgLib.flakeURL flake;
                # editorconfig-checker-disable
                fragment = jnfsgLib.percent-encodeAll configToInstallName;
                # editorconfig-checker-enable
                fullURL = "${baseURL}#${fragment}";
                disk = configToInstall.config.disko.devices.disk.main;
                diskPath = disk.device;
              in
              ''
                declare -rx NIX_CONFIG='
                  allow-unsafe-native-code-during-evaluation = true
                '
                disko-install \
                    --flake ${escapeShellArg fullURL} \
                    --disk main ${escapeShellArg diskPath} \
                    --write-efi-boot-entries
              '';
          };
        targets.unattended-install = {
          wants = [ "unattended-install.service" ];
          # editorconfig-checker-disable
          description = "Automatically install NixOS (${configToInstallName})";
          # editorconfig-checker-enable
        };
      };
      # editorconfig-checker-disable
      specialisation.unattendedInstall.configuration.boot.kernelParams = [
        "systemd.unit=unattended-install.target"
      ];
      # editorconfig-checker-enable

      services.getty.autologinUser = "root";
    };
}
