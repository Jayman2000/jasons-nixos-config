"""SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2023)
"""
from argparse import ArgumentParser, Namespace
from collections.abc import Callable, Iterable, Sequence
from datetime import date, datetime, UTC
from hashlib import file_digest, sha256
from pathlib import Path
from subprocess import CalledProcessError, CompletedProcess, run
from sys import stderr
from tomllib import load as load_toml
from typing import Final, NamedTuple, Optional, Self
from warnings import warn

from dns.rdataset import Rdataset
from dns.rdatatype import SOA as SOA_TYPE
from dns.rdtypes.ANY.SOA import SOA as SOARecord
from dns.resolver import Answer, resolve
from dns.zone import Zone, from_file as zone_from_file


DOMAIN : Final[str] = "test.jasonyundt.email"
HASH_ALGORITHM : Final[Callable] = sha256

HASH_FILE_TEMPLATE : Final[str] = (
"".join("# " + line for line in __doc__.splitlines(keepends=True))
+ """

serial = {}
hash = 0x{}
"""
)

HASH_SIZE : Final[int] = HASH_ALGORITHM().digest_size
NO_SOA_IN_DNS : Final[str] = \
		f"Failed to find SOA record for “{DOMAIN}”."
NO_SOA_IN_FILE : Final[str] = "“{}” doesn’t contain any SOA records."
RFC_1912_URL : Final[str] = \
	"https://www.rfc-editor.org/rfc/rfc1912.html"
# We’re hard coding the timezone here to make this script do the same
# thing regardless of where this script is run. I’m choosing UTC because
# that’s the timezone that mailserver.test.jasonyundt.email uses.
TODAY : Final[date] = datetime.now(UTC).date()
TOO_MANY_SOA : Final[str] = (
		"“{}” has more than one SOA record. Only using the"
		+ "first one…"
)
DESCRIPTION : Final[str] = (
		"Checks a zone file’s SOA record’s serial number and "
		+ "bumps it if necessary."
)
PARSER : Final[ArgumentParser] = ArgumentParser(
	description=DESCRIPTION
)
PARSER.add_argument(
	'zone_file_paths',
	nargs='*',
	type=Path,
	metavar="ZONE_FILE"
)
ARGS : Final[Namespace] = PARSER.parse_args()


class SerialNumber(int):
	YEAR_MULTIPLIER : Final[int] = 1_00_00_00
	MONTH_MULTIPLIER : Final[int] = 1_00_00
	DAY_MULTIPLIER : Final[int] = 1_00

	# Thanks you to John La Rooy
	# (<https://stackoverflow.com/users/174728/john-la-rooy>) for
	# this idea: <https://stackoverflow.com/a/2673863/7593853>.
	def __new__(cls, *args, **kwargs) -> Self:
		return int.__new__(cls, *args, **kwargs)

	def __init__(self, *args, **kwargs) -> None:
		if self < 0 or self > 9_999_999_999:
			warn(
					f"{self:010} doesn’t look like "
					+ "a valid serial number. "
					+ "Serial numbers should be "
					+ "positive and have ten or "
					+ "less digits. See section 2.2"
					+ "of RFC 1912 for details: "
					+ f"<{RFC_1912_URL}>."
			)

	@classmethod
	def new_serial_for_today(cls) -> Self:
		return cls(
				TODAY.year * cls.YEAR_MULTIPLIER
				+ TODAY.month * cls.MONTH_MULTIPLIER
				+ TODAY.day * cls.DAY_MULTIPLIER
		)

	def year(self) -> int:
		return self // self.YEAR_MULTIPLIER

	def month(self) -> int:
		return (self // self.MONTH_MULTIPLIER) % 1_00

	def day(self) -> int:
		return (self // self.DAY_MULTIPLIER) % 1_00

	def revision(self) -> int:
		return self % 1_00

	def date(self) -> date:
		return date(self.year(), self.month(), self.day())

	def bumped(self) -> Self:
		if self.date() < TODAY:
			return self.new_serial_for_today()
		elif self.revision() < 99:
			return type(self)(self + 1)
		else:
			raise OverflowError(
				"The revision number for this serial "
				+ f"number ({self}) is too high to be"
				+ "bumped. You can make a maximum of "
				+ "100 changes to a zone file per day "
				+ "using the numbering scheme laid out"
				+ "in section 2.2 or RFC 1912: "
				+ f"<{RFC_1912_URL}>."
			)


class ZoneFileInfo(NamedTuple):
	serial : SerialNumber
	hash : bytes


def printerr(*args, **kwargs) -> None:
	kwargs["file"] = stderr
	print(*args, **kwargs)


def current_zf_serial_number(zone_file_path : Path) -> SerialNumber:
	with zone_file_path.open() as zone_file:
		ZONE : Final[Zone] = zone_from_file(zone_file)
	RECORDS : Final[Rdataset] = ZONE.find_rdataset("@", SOA_TYPE)
	if len(RECORDS) == 0:
		raise ValueError(NO_SOA_IN_FILE.format(zone_file_path))
	if len(RECORDS) > 1:
		warn(TOO_MANY_SOA.format(zone_file_path))
	SOA_RECORD : Final[SOARecord] = RECORDS[0]
	return SerialNumber(SOA_RECORD.serial)


def current_zf_hash(zone_file_path : Path) -> bytes:
	with zone_file_path.open('rb') as zone_file:
		return file_digest(zone_file, HASH_ALGORITHM).digest()


def current_zf_info(zone_file_path : Path) -> ZoneFileInfo:
	return ZoneFileInfo(
			current_zf_serial_number(zone_file_path),
			current_zf_hash(zone_file_path)
	)


def zf_hash_file_path(zone_file_path : Path) -> Path:
	return Path(
			*zone_file_path.parts[:-1],
			zone_file_path.parts[-1] + ".hash"
	)


def previous_zf_info(zone_file_path : Path) -> Optional[ZoneFileInfo]:
	HASH_FILE_PATH : Final[Path] = zf_hash_file_path(zone_file_path)
	if HASH_FILE_PATH.exists():
		with HASH_FILE_PATH.open('rb') as hash_file:
			FROM_HASH_FILE : Final[dict] = \
				load_toml(hash_file)
		return ZoneFileInfo(
				SerialNumber(FROM_HASH_FILE["serial"]),
				FROM_HASH_FILE["hash"].to_bytes(HASH_SIZE)
		)
	else:
		return None


def serial_number_in_dns() -> Optional[SerialNumber]:
	ANSWERS : Final[Answer] = resolve(DOMAIN, SOA_TYPE)
	if len(ANSWERS) == 0:
		return None
	else:
		SOA_RECORD : Final[SOARecord] = ANSWERS[0]
		return SerialNumber(SOA_RECORD.serial)


def write_new_hash_file(
		zone_file_path : Path,
		serial_number : SerialNumber
) -> None:
	HASH : Final[str] = current_zf_hash(zone_file_path).hex()
	HASH_FILE_CONTENTS : Final [str] = \
			HASH_FILE_TEMPLATE.format(
					serial_number,
					HASH
			)
	with zf_hash_file_path(zone_file_path).open('w') as file:
		file.write(HASH_FILE_CONTENTS)


SERIAL_NUMBER_IN_DNS : Final[Optional[SerialNumber]] = \
		serial_number_in_dns()
def potentially_bump_serial_number(zone_file_path : Path) -> None:
	need_to_bump : bool = False
	new_serial : SerialNumber
	CURRENT_ZF : Final[ZoneFileInfo] = \
			current_zf_info(zone_file_path)
	if (
			SERIAL_NUMBER_IN_DNS is not None
			and CURRENT_ZF.serial < SERIAL_NUMBER_IN_DNS
	):
		need_to_bump = True
		new_serial = SERIAL_NUMBER_IN_DNS.bumped()
	else:
		PREVIOUS_ZF : Final[Optional[ZoneFileInfo]] = \
			previous_zf_info(zone_file_path)
		if (
				PREVIOUS_ZF is not None
				and PREVIOUS_ZF.serial == CURRENT_ZF.serial
				and PREVIOUS_ZF.hash != CURRENT_ZF.hash
		):
			need_to_bump = True
			new_serial = CURRENT_ZF.serial.bumped()

	OLD_SERIAL : Final[SerialNumber] = CURRENT_ZF.serial
	if need_to_bump:
		with zone_file_path.open() as old_zf:
			OLD_ZF_CONTENTS : Final[str] = old_zf.read()
		NEW_ZF_CONTENTS : Final[str] = OLD_ZF_CONTENTS.replace(
				str(OLD_SERIAL),
				str(new_serial)
		)
		with zone_file_path.open('w') as new_zf:
			new_zf.write(NEW_ZF_CONTENTS)
	else:
		new_serial = OLD_SERIAL

	write_new_hash_file(zone_file_path, new_serial)


def file_paths_in_git_repo() -> Iterable[Path]:
	try:
		RESULT : Final[CompletedProcess] = run(
				("git", "ls-files", "-z"),
				capture_output=True,
				check=True,
				text=True
		)
		LIST : Final[Sequence] = RESULT.stdout.split(sep="\0")
		# str.split() assumes that the separator is in between
		# each of the items in the string. The string here is
		# actually NUL terminated, not NUL delimited. There’s a
		# NUL after every item in the string, including the last
		# one. As a result, str.split sees the final NUL
		# terminator and assumes that there’s just an empty
		# string after it. That’s why we have to ignore the last
		# item in the LIST.
		for path_string in LIST[:-1]:
			yield Path(path_string)
	except FileNotFoundError as error:
		printerr("ERROR: git command not found.")
		raise error
	except CalledProcessError as error:
		printerr("$", *error.cmd)
		printerr(error.stderr)
		raise error



def paths_to_process() -> Iterable[Path]:
	if len(ARGS.zone_file_paths) == 0:
		for file_path in file_paths_in_git_repo():
			if file_path.suffix == ".zone":
				yield file_path
	else:
		return ARGS.zone_file_paths


for zone_file_path in paths_to_process():
	potentially_bump_serial_number(zone_file_path)
