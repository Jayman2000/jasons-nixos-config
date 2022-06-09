<!--
SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2021–2022)
-->

# Copying Information for Jason’s [NixOS] Config

This project uses [SPDX file tags] to declare its copying information.

## SPDX Metadata Files

Normally, [SPDX file tags] are put in the files they describe. For example, in
a comment at the top of this file, there’s an [SPDX file tag] which says that
“Jason Yundt” [contributed](https://spdx.github.io/spdx-spec/file-information/#814-file-contributor-field)
to this file.

Sometimes, for technical reasons, an [SPDX file tag] can’t be included in the
file itself. For example, [`Pipfile.lock`](https://pipenv.pypa.io/en/stable/basics/)
is a [JSON] file. [JSON files can’t have comments](https://stackoverflow.com/questions/244777/can-comments-be-used-in-json),
so there isn’t a good place to put an [SPDX file tag] in a [JSON] file.

The solution: SPDX Metadata Files. SPDX Metadata Files are [plain text](https://www.rfc-editor.org/rfc/rfc2046.html#section-4.1)
files who’s names end with “`.spdx-meta`”. Every SPDX Metadata File has a
companion file. A SPDX Metadata File must be in the same folder as its
companion file in order to be valid. The SPDX Metadata File’s name must be the
companion file’s name with “`.spdx-meta`” added to the end. For example,
consider the following directory tree:

	.
	├── a
	│   ├── foo.txt
	│   └── foo.txt.spdx-meta
	├── b
	│   └── bar.txt.spdx-meta
	├── bar.txt
	└── bar.txt.spdx-meta

In this example,

- `./a/foo.txt.spdx-meta` is an SPDX Metadata File because its name ends with
“`.spdx-meta`”. Its companion file is `./a/foo.txt`.
- `./bar.txt.spdx-meta` is also an SPDX Metadata File. Its companion file is
`./bar.txt`.
- `./b/bar.txt.spdx-meta` is an SPDX Metadata File, but it’s an invalid one.
It’s an SPDX Metadata File because its name ends with “`.spdx-meta`”. It’s
invalid because it has no companion file.

SPDX Metadata Files describe their companion files; [SPDX file tags] in SPDX
Metadata Files don’t describe the SPDX Metadata Files that they’re in.

Consider that previous example again. If `./a/foo.txt.spdx-meta` contained
“SPDX-FileType” followed by a colon, a space and “DOCUMENTATION”, that would
mean that `./a/foo.txt` is a documentation file. That piece of information
alone tells you nothing about `./a/foo.txt.spdx-meta`.

All SPDX Metadata Files in this repo are dedicated to the public domain using
[the CC0 1.0 Universal Public Domain Dedication](https://creativecommons.org/publicdomain/zero/1.0/).

[JSON]: https://www.json.org/json-en.html
[NixOS]: https://nixos.org/
[SPDX file tag]: https://spdx.github.io/spdx-spec/file-tags/
[SPDX file tags]: https://spdx.github.io/spdx-spec/file-tags/
