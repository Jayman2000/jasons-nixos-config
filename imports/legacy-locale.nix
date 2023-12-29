# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2023)
{ options, ...}:
{
	# The glibc-locales package “[c]heck[s] that all locales to be
	# built are supported” [1]. Unfortunately, one of the locales
	# that I want is unsupported. This overlay circumvents that
	# check in the glibc-locales package.
	#
	# Thank you, jchw, for this idea [2].
	#
	# [1]: <https://github.com/NixOS/nixpkgs/blob/d02d818f22c777aa4e854efc3242ec451e5d462a/pkgs/development/libraries/glibc/locales.nix#L44>
	# [2]: <https://discourse.nixos.org/t/building-unsupported-locales-ja-jp-sjis/3612/6?u=jasonyundt>.
	nixpkgs.overlays = let
		from = ["  false\nfi"];
		to = ["fi"];
		patchIfStatement = (string:
			builtins.replaceStrings from to string
		);
		glibcOverride = (finalAttrs: prevAttrs: {
			preBuild = patchIfStatement prevAttrs.preBuild;
		});
		nixpkgsOverlay = (self: super: {
			glibcLocales = super.glibcLocales.overrideAttrs glibcOverride;
		});
	in
		[ nixpkgsOverlay ];
	# Most of the time, I’m going to be using a UTF-8 locale. That
	# being said, not everyone uses a UTF-8 locale, and I’ve
	# accidentally written software that breaks if you don’t use a
	# UTF-8 locale. Specifically, I had written software that
	# assumed that Python’s open() function would default to using
	# UTF-8. In reality, Python’s open() function defaults to using
	# your locale encoding [1], and using a UTF-8 locale encoding by
	# default is still a beta feature on Windows [2][3].
	#
	# I’m adding an extra, non-UTF-8 locale here so that I can test
	# out software to make sure that it works on systems that don’t
	# use a UTF-8 locale. Specifically, I chose to create a locale
	# that uses plain-old ASCII. Pretty much every character
	# set contains everything in ASCII plus more characters. The
	# only exceptions that I’m aware of are ASCII-variants that
	# replace certain characters (example: [4]) and EBCDIC. I tried
	# creating an EBCDIC locale, but the build process crashed with
	# an error about EBCDIC not being ASCII-compatible.
	#
	# [1]: <https://docs.python.org/3/library/functions.html#open>
	# [2]: <https://docs.python.org/3/glossary.html#term-locale-encoding>
	# [3]: <https://learn.microsoft.com/en-us/windows/apps/design/globalizing/use-utf8-code-page#set-a-process-code-page-to-utf-8>
	# [4]: <https://en.wikipedia.org/wiki/Code_page_1013>
	i18n.supportedLocales =
		# Thanks you, mvnetbiz, for this idea:
		# <https://discourse.nixos.org/t/how-can-i-augment-a-default-value-instead-of-overriding-it/14774/4?u=jasonyundt>
		options.i18n.supportedLocales.default
		++ [ "en_US.ANSI_X3.4-1968/ANSI_X3.4-1968" ];
}
