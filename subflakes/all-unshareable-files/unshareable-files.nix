{ lib, requireFile }: let
  mkTouhouInstallFloppyImage = { gameNumber, diskNumber ? null, hash }: let
    name = (
      "TH${lib.toString gameNumber}"
      + lib.strings.optionalString (diskNumber != null) "DISK${lib.toString diskNumber}"
      + ".FDI"
    );
  in requireFile {
    inherit name;
    message = ''
      You must manually add ${name} to the Nix store by running this command:

        nix-store --add-fixed sha256 ${lib.strings.escapeShellArg name}

      ${name} is an Anex86 PC98 floppy image [1] of Touhou ${lib.toString gameNumber}’s
      installation floppy${lib.strings.optionalString (diskNumber != null) " disk #${lib.toString diskNumber}"}.

      [1]: <http://fileformats.archiveteam.org/wiki/Anex86_PC98_floppy_image>
    '';
    inherit hash;
  };
in [
  (mkTouhouInstallFloppyImage {
    gameNumber = 1;
    hash = "sha256-uu2bMyXisT2OjwCOEWXwKBlNkOb2cEXnTeMuI21KGu0=";
  })
  (mkTouhouInstallFloppyImage {
    gameNumber = 2;
    hash = "sha256-3xlx634DIcUsDl4Ej+sQp1StbY+sBkFOb28+CKVTDO4=";
  })
  (mkTouhouInstallFloppyImage {
    gameNumber = 3;
    diskNumber = 1;
    hash = "sha256-a0uXGldtDR1TDHoL3SFSDhTQj53O5Eoz5bZZm1Sp+jQ=";
  })
  (mkTouhouInstallFloppyImage {
    gameNumber = 3;
    diskNumber = 2;
    hash = "sha256-wV+InK9TrsRSzfkpqpXwT5TxCWxo5DZlTgw8Sgx09OU=";
  })
  (mkTouhouInstallFloppyImage {
    gameNumber = 4;
    diskNumber = 1;
    hash = "sha256-tbygNd12I8rsMZR4iH3LcEMUQ3Y87s331IcAHz2Dos4=";
  })
  (mkTouhouInstallFloppyImage {
    gameNumber = 4;
    diskNumber = 2;
    hash = "sha256-Dgwti8Fub0wayK++JIVGVD1Yr5H9BAF3Q3CCP+5L0ck=";
  })
  (mkTouhouInstallFloppyImage {
    gameNumber = 5;
    diskNumber = 1;
    hash = "sha256-Pi6KFhr5UCp1+brFY7B+V9AUiu70Zlx9MZX+SetJ9Ak=";
  })
  (mkTouhouInstallFloppyImage {
    gameNumber = 5;
    diskNumber = 2;
    hash = "sha256-cm4raa9OoURQzyY2gGHSX3Ti/tYbXJjN90g4Uf5haoU=";
  })
]
