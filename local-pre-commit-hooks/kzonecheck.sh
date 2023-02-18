#!/usr/bin/env bash
# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2023)
set -e

# This script is much more complicated that what it should be. It only
# exists to run one command (kzonecheck).
#
# For one thing, I would like to have just used a remote pre-commit hook
# instead of a local one. Unfortunately, it doesn’t look like there’s a
# pre-commit hook for kzonecheck yet. I might end up creating one in the
# future, but I’m going to use a local one for now.
#
# One problem with setting up a local pre-commit hook is that knot-dns
# is written in C [1], and there isn’t a pre-commit hook language for C
# [2]. There is a hook language for conda [3], and conda does say that
# it supports the C programming language [4], but I don’t know how to
# use conda. If I end up creating a proper remote hook in the future,
# conda might be how I do so.
#
# This leaves me with two options. I can either use the script [5] or
# the system [6] language. The disadvantage of using either of those two
# languages is that pre-commit won’t be able to install any of the
# hook’s dependencies for you.
#
# This seems like the perfect opportunity to write a script that uses
# nix-shell as an interpreter [7]. That way, users would only have to
# make sure that Nix is installed. nix-shell would then install knot-dns
# only if it’s needed. Unfortunately, for whatever reason, pre-commit
# seems to always use bash as the interpreter, even when the shebang
# says to use nix-shell. In this scenario, ./kzonecheck.sh would work
# fine, but running that same command as a pre-commit hook would fail
# with a command-not-found error for kzonecheck.
#
# OK, so now we have to write a script that uses bash as the interpreter
# and then runs nix-shell to make sure that we have access to the
# kzonecheck command. Unfortunately, nix-shell’s --run option only takes
# one argument. If you were to run
#
# nix-shell -p bash --run echo 1 2 3
#
# you would get an error. Instead, you have to do this:
#
# nix-shell -p bash --run "echo 1 2 3"
#
# Here’s the problem: we have to take the arguments that are passed to
# this script and include them in nix-shell’s --run argument. This
# wouldn’t work:
#
# nix-shell -p knot-dns --run "kzonecheck $@"
#
# because "$@" would be split into addition nix-shell arguments instead
# of addtional kzonecheck arguments [8]. This would be a little bit
# better:
#
# nix-shell -p knot-dns --run "kzonecheck $*"
#
# but still wouldn’t work properly in all situations. If an argument
# passed to this script contained spaces, then it would get split into
# multiple words by the bash instance that nix-shell spawns [9].
#
# All of that is why I’m creating an array named args. I need to be able
# to take the "$@" variable that this script sees and transform it into
# something that can be recreated inside the instance of bash that’s
# spawned by nix-shell. Making args an array makes it easy to turn it
# back into a list of arguments later while still handling arguments
# that contain whitespace properly.
#
# Thanks to kojiro (<https://stackoverflow.com/users/418413/kojiro>) for
# pointing me in the right direction:
# <https://stackoverflow.com/a/12711837/7593853>.
#
# [1]: <https://gitlab.nic.cz/knot/knot-dns>
# [2]: <https://pre-commit.com/#supported-languages>
# [3]: <https://pre-commit.com/#conda>
# [4]: <https://docs.conda.io/en/latest/>
# [5]: <https://pre-commit.com/#script>
# [6]: <https://pre-commit.com/#system>
# [7]: <https://nixos.org/manual/nix/stable/command-ref/nix-shell.html#use-as-a--interpreter>
# [8]: <https://www.gnu.org/software/bash/manual/bash.html#index-_0040>
# [9]: <https://www.gnu.org/software/bash/manual/bash.html#index-_002a>
readonly args=( "$@" )
# This looks a little bit weird because I’m creating a single argument
# using two sets of quotation marks. I need to use double quotes for the
# first half of the argument because I need the $(…) to be expanded by
# the instance of bash that this script runs in. The args variable only
# exists in that instance of bash at first. I need to use single quotes
# for the second half of the argument because I need the ${…} part to be
# expanded by the instance of bash that’s spawned by nix-shell.
# We need to prevent the ${…} part from expanding too early or else
# elements of args that contain spaces will get split into multiple
# words.
nix-shell -p knot-dns --run "$(declare -p args);"'kzonecheck "${args[@]}"'
