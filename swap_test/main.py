# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2022)
from argparse import ArgumentParser
from collections import deque
from pathlib import Path
from time import sleep
from typing import Final
from random import randbytes, randrange

from psutil import virtual_memory

MIB: Final[int] = 1024 * 1024  # Number of bytes in a mebibyte.
ARGUMENT_PARSER: Final[ArgumentParser] = ArgumentParser(
		description="Allocates a lot of memory to test swapspace."
)
ARGUMENT_PARSER.add_argument(
		'memory_limit',
		default=10*MIB,  # 10 MiB, an arbitrary number.
		type=int,
		help="Stop allocating once this much virtual memory is in use.",
		metavar="BYTES"
)
MEMORY_LIMIT: Final[int] = ARGUMENT_PARSER.parse_args().memory_limit

def escape_hatch_not_active() -> bool:
	return not Path("escape_hatch").exists()

try:
	ARBITRARY_DATA: Final[deque] = deque()
	while escape_hatch_not_active() and virtual_memory().used < MEMORY_LIMIT:
		ARBITRARY_DATA.append(randbytes(MIB))
	print(f"Current memory usage: {virtual_memory().used}")
	while escape_hatch_not_active():
		ARBITRARY_DATA[randrange(0, len(ARBITRARY_DATA))] = randbytes(MIB)
		sleep(1/32)
except KeyboardInterrupt:
	pass
