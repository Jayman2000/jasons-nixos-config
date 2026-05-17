# SPDX-License-Identi
# SPDX-FileCopyrightText: 2026 Jason Yundt <jason@jasonyundt.email>
{
  perSystem,
  pkgs,
  pname,
}:
pkgs.runCommand pname {
  nativeBuildInputs = with pkgs; [
    dos2unix
    dosbox-x
    iconv
  ];
  availableUnshareableFiles = perSystem.self.available-unshareable-files;
  dosBoxConf = ./dosbox-x.conf;
  installBatchFiles = ./install-batch-files;
  # TODO: Official update patch for one of the games.
  touhou5100To101Update = pkgs.fetchzip {
    url = "http://www.kt.rim.or.jp/~aotaka/am/kaiki101.lzh";
    hash = "";
    nativeBuildInputs = [ pkgs.lhasa ];
  };
  # TODO: Actually apply the englishPatches.
  englishPatches = pkgs.fetchtorrent {
    url = "https://archive.org/download/touhou-project-pc-98-complete-english-patch-pack-100/touhou-project-pc-98-complete-english-patch-pack-100_archive.torrent";
    hash = "sha256-dxohYOUJqJEFa6YRWURJfAAFd0lejdTWZ7gXcKfyft0=";
  };
} ''
  # This is needed or else a later iconv command might fail.
  export LANG=C.UTF-8

  th1_floppy_set=("$availableUnshareableFiles/TH1.FDI")
  th2_floppy_set=("$availableUnshareableFiles/TH2.FDI")
  th3_floppy_set=(
    "$availableUnshareableFiles/TH3DISK1.FDI"
    "$availableUnshareableFiles/TH3DISK2.FDI"
  )
  th4_floppy_set=(
    "$availableUnshareableFiles/TH4DISK1.FDI"
    "$availableUnshareableFiles/TH4DISK2.FDI"
  )
  th5_floppy_set=(
    "$availableUnshareableFiles/TH5DISK1.FDI"
    "$availableUnshareableFiles/TH5DISK2.FDI"
  )
  floppy_image_sets=(
    th1_floppy_set
    th2_floppy_set
    th3_floppy_set
    th4_floppy_set
    th5_floppy_set
  )

  mkdir --parents Drives/C
  for index in "''${!floppy_image_sets[@]}"
  do
    game_number="$(( "$index" + 1 ))"
    declare -n floppy_image_set="''${floppy_image_sets["$index"]}"
    all_floppy_images_found=1
    for floppy_image in "''${floppy_image_set[@]}"
    do
      if [ -e "$floppy_image" ]
      then
        ln --symbolic -- "$floppy_image" .
      else
        >&2 printf 'WARNING: %q does not exist.\n' "$floppy_image"
        all_floppy_images_found=0
      fi
    done
    if [ "$all_floppy_images_found" -eq 0 ]
    then
      >&2 printf \
        'WARNING: Missing at least one floppy disk image for Touhou %s. Skipping install of Touhou %s…\n' \
        "$game_number" \
        "$game_number"
    else
      printf 'Installing Touhou %s…\n' "$game_number"
      ln \
        --force \
        --symbolic \
        -- \
        "$installBatchFiles/$game_number.BAT" \
        Drives/C/INSTALL.BAT
      dosbox-x -exit -conf "$dosBoxConf"
      # TODO: It would be nice if we could use DOSBox-X’s serial1=log feature
      # [1] instead of reading a log file after the fact. Unfortunately,
      # DOSBox-X doesn’t support PC-98 serial port emulation [2].
      #
      # [1]: <https://github.com/joncampbell123/dosbox-x/commit/622424839a76515408f572ac58a75858ab5f3b5e>
      # [2]: <https://github.com/joncampbell123/dosbox-x/issues/5858>
      printf 'Finished installing Touhou %s. Install log:\n' "$game_number"
      iconv --from-code=SHIFT-JIS Drives/C/LOG.TXT | dos2unix
      rm Drives/C/LOG.TXT
    fi
  done

  rm Drives/C/INSTALL.BAT
  cp --recursive -- Drives/C "$out"
''
