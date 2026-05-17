import argparse
import os
import pathlib
import sys

from typing import Final

import platformdirs


def main() -> int:
    ARGUMENT_PARSER: Final = argparse.ArgumentParser(
        description="Command-line launcher for PC-98 Touhou games"
    )
    ARGUMENT_PARSER.add_argument(
        "game_number",
        type=int,
        choices=(1, 2, 3, 4, 5),
        help=(
            "Which game will be launched (Touhou 1, Touhou 2, "
            "Touhou 3, Touhou 4 or Touhou 5)."
        )
        # TODO: metavar?
    )
    ARGS: Final = ARGUMENT_PARSER.parse_args()

    APP_NAME: Final = "launch-pc-98-touhou-game"
    PLATFORM_DIRS: Final = platformdirs.PlatformDirs(
        appname=APP_NAME,
        appauthor="Jason Yundt"
    )
    C_DRIVE: Final = PLATFORM_DIRS.user_data_path / "Drives" / "C"
    PC_98_TOUHOU_GAME_DATA: Final = pathlib.Path(
        os.environ["PC_98_TOUHOU_GAME_DATA"]
    )
    TH_DIR: Final = pathlib.Path(f"TH{ARGS.game_number}")
    CLEAN_TH_DIR: Final = PC_98_TOUHOU_GAME_DATA / TH_DIR
    USER_TH_DIR: Final = C_DRIVE / TH_DIR

    if not CLEAN_TH_DIR.exists():
        MESSAGE: Final = (
            f"ERROR: {str(CLEAN_TH_DIR)!r} does not exist. This "
            "indicates that one or more of the install floppies for "
            f"Touhou {ARGS.game_number} was not available when "
            f"{APP_NAME} was built. Cannot launch Touhou "
            f"{ARGS.game_number}."
        )
        print(MESSAGE, file=sys.stderr)
        # This is EX_UNAVAILABLE from <man:sysexits.h(3head)>.
        return 69

    C_DRIVE.mkdir(parents=True, exist_ok=True)
    if not USER_TH_DIR.exists():
        CLEAN_TH_DIR.copy(USER_TH_DIR)

    os.chdir(PLATFORM_DIRS.user_data_path)
    os.execlp(
        "dosbox-x",
        "dosbox-x",
        "-conf",
        pathlib.Path(os.environ["DOSBOX_X_CONF"]),
        "-c",
        f"CD \\TH{ARGS.game_number}\\GAME",
        "-c",
        "GAME.BAT"
    )
