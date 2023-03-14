"""SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2023)
"""
from argparse import ArgumentParser, Namespace
from collections.abc import Iterable, Sequence
from datetime import date, datetime, UTC
from hashlib import file_digest
from pathlib import Path
from re import compile as re_compile, Match, Pattern
from sys import stderr
from typing import Final


COMMENT_REGEX : Final[Pattern] = re_compile(r"\s")
SERIAL_COMMENT : Final[str] = "; [Serial number]"
SERIAL_REGEX : Final[Pattern] = re_compile(r"\d+ +(?=; \[Serial number\])")
HASH_FILE_SPDX_HEADER : Final[str] = "".join(
		"; " + line for line in __doc__.splitlines(keepends=True)
)
DESCRIPTION : Final[str] = (
		"Checks a zone file’s SOA record’s serial number and "
		+ "bumps it if necessary."
)


def printerr(message : str) -> None:
	print("ERROR: " + message, file=stderr)


def today_utc() -> date:
	return datetime.now(UTC).date()


def hex_hash(path : Path) -> str:
	with path.open('rb') as file:
		return file_digest(file, "sha256").hexdigest()


def write_new_zone_hash_file(
		path : Path,
		serial_number : str,
		hex_hash : str
) -> None:
	with path.open('w') as file:
		file.write(HASH_FILE_SPDX_HEADER)
		file.write(";\n")
		file.write(
				"; This is the hash of a zone file "
				+ "who’s serial number is "
				+ f"{serial_number}:\n",
		)
		file.write(f"{hex_hash}\n")


def process_zone_path(zone_path : Path) -> None:
	zone_contents : str
	matches : Sequence[str]
	with zone_path.open() as file:
		zone_contents = file.read()
		matches = SERIAL_REGEX.findall(zone_contents)
	if len(matches) == 1:
		current_serial : str = matches[0].strip()
		current_zone_hash : str = hex_hash(zone_path)

		# Example: if zone_path is
		#
		# Path("knot-dns", "storage", "example.com.zone")
		#
		# then zone_hash_file_path will be
		#
		# Path("knot-dns", "storage", "example.com.zone.hash")
		zone_hash_file_path : Path = Path(
				*zone_path.parts[:-1],
				zone_path.parts[-1] + ".hash"
		)
		if zone_hash_file_path.is_file():
			with zone_hash_file_path.open() as file:
				lines : Iterable[str] = file.readlines()
			previous_zone_hash : str = ""
			for line in lines:
				for character in line:
					if character == ";":
						break
					elif not character.isspace():
						previous_zone_hash += character

			if previous_zone_hash != current_zone_hash:
				current_serial_date : date = date(
						int(current_serial[:4]),
						int(current_serial[4:6]),
						int(current_serial[6:8])
				)
				current_serial_rev : int = int(current_serial[8:])

				# Generate a new serial number
				new_serial_date : date = today_utc()
				new_serial_rev : int
				if current_serial_date == new_serial_date:
					new_serial_rev = current_serial_rev + 1
					if new_serial_rev > 99:
						printerr(
							"It looks like "
							+ "“"
							+ str(zone_path)
							+ "” was "
							+ "already "
							+ "updated "
							+ "100 times "
							+ "today. "
							+ "Unable to "
							+ "generate a "
							+ "new serial "
							+ "number that "
							+ "follows the "
							+ "pattern "
							+ "recommended "
							+ "by RRC 1912,"
							+ " section "
							+ "2.2."
						)
						# Process the next
						# command-line argument:
						return
				else:
					new_serial_rev = 0
				new_serial : str
				new_serial = "{:04}{:02}{:02}{:02}"
				new_serial = new_serial.format(
						new_serial_date.year,
						new_serial_date.month,
						new_serial_date.day,
						new_serial_rev
				)
				new_zone_contents : str
				# The “+ "  "” part is just there to
				# put a little bit of space in between
				# the serial number and the comment.
				new_zone_contents = SERIAL_REGEX.sub(
						new_serial + "  ",
						zone_contents
				)
				with zone_path.open('w') as file:
					file.write(new_zone_contents)
				new_zone_hash : str
				new_zone_hash = hex_hash(zone_path)
				write_new_zone_hash_file(
						zone_hash_file_path,
						new_serial,
						new_zone_hash
				)
		elif zone_hash_file_path.is_dir():
			printerr(
				f"“{zone_hash_file_path}” is a "
				+ "directory. It should either be a "
				+ "file or not exist."
			)
		else:
			write_new_zone_hash_file(
					zone_hash_file_path,
					current_serial,
					current_zone_hash
			)
	elif len(matches) == 0:
		printerr(
				"Couldn’t find SOA serial number "
				+ "comment. The serial number should be"
				+ " on its own line, followed by a "
				+ "comment that looks like this:\n\n"
				+ SERIAL_COMMENT
		)
	else:
		printerr(
				f"It looks like {zone_path} contains "
				+ "multiple SOA serial numbers. There "
				+ "should be only one "
				+ f"“{SERIAL_COMMENT}” comment."
		)


def update_serial_numbers() -> None:
	PARSER : Final[ArgumentParser] = ArgumentParser(
			description=DESCRIPTION
	)
	PARSER.add_argument(
			'zone_files',
			nargs='+',
			type=Path,
			metavar="ZONE_FILE"
	)
	ARGS : Final[Namespace] = PARSER.parse_args()
	for zone_path in ARGS.zone_files:
			process_zone_path(zone_path)


if __name__ == "__main__":
	update_serial_numbers()
