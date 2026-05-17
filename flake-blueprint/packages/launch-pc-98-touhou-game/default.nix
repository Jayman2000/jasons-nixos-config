{
  perSystem,
  pkgs,
  pname,
}:
let
  pythonPackages = pkgs.python314Packages;
in pythonPackages.buildPythonApplication (finalAttrs: let
  pyprojectData = pkgs.lib.trivial.importTOML "${finalAttrs.src}/pyproject.toml";
in {
  pname = assert pkgs.lib.asserts.assertMsg (pyprojectData.project.name == pname) "Package directory name and Python distribution package name do not match."; pname;
  inherit (pyprojectData.project) version;
  src = pkgs.lib.fileset.toSource {
    root = ./.;
    fileset = pkgs.lib.fileset.union ./pyproject.toml ./src;
  };

  pyproject = true;
  build-system = [ pythonPackages.uv-build ];
  dependencies = [ pythonPackages.platformdirs ];

  __structuredAttrs = true;
  passthru.dosboxXConf = ./dosbox-x.conf;
  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (pkgs.lib.strings.makeBinPath [ pkgs.dosbox-x ])
    "--set"
    "PC_98_TOUHOU_GAME_DATA"
    perSystem.self.pc-98-touhou-game-data
    "--set"
    "DOSBOX_X_CONF"
    finalAttrs.passthru.dosboxXConf
  ];

  meta.mainProgram = pname;
})
