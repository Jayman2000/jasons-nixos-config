# SPDX-License-Identifier: LicenseRef-MIT-JY
# SPDX-FileCopyrightText: 2022 Jason Yundt <jason@jasonyundt.email>
with import <nixpkgs> { };

stdenv.mkDerivation rec {
	pname = "swapspace";
	version = "1.17";
	src = fetchFromGitHub {
		owner = "Tookmund";
		repo = "Swapspace";
		rev = "v${version}";
		hash = "sha256-v1kSkepZm6+S4wf86ETgQzEAZBLJ2jQBgCRdF7yvuxs=";
	};
	buildInputs = [ automake autoconf ];

	# See <https://github.com/Tookmund/Swapspace/blob/v1.17/README.md#where-to-start>.
	preConfigure = "autoreconf -i";

	# If we don’t redefine ETCPREFIX and VARPREFIX, then swapspace would
	# (by default) look for its config file in the Nix store and try to
	# create swap files in the Nix store. Unfortunately, redefining
	# ETCPREFIX and VARPREFIX causes extra compiler warnings.
	#
	# We could do
	#   configureFlags = [ "--sysconfdir=/etc" "--localstatedir=/var" ];
	# That would set both ETCPREFIX and VARPREFIX correctly without
	# redefining them. Unfortunately, that would also cause “make install”
	# to attempt to create files in /etc and /var and then fail with a
	# permission denied error.
	preBuild = ''
		# Why do the double quotes have to be escaped here? Isn’t the
		# fact that they’re in single quotes enough?
		makeFlagsArray+=(CFLAGS='-DETCPREFIX=\"/etc\" -DVARPREFIX=\"var\"')
	'';
	postInstall = ''
		# Upstream tries to install the man page [1], but for whatever
		# reason it doesn’t get installed.
		#
		# [1]: <https://github.com/Tookmund/Swapspace/blob/62c25dbc3f4741f23c99b6c9310c17d63391ad10/Makefile.static#L25>
		install -Dm644 doc/swapspace.8 "$out/share/man/man8"
	'';

	outputs = [ "bin" "man" "out" ];
}
