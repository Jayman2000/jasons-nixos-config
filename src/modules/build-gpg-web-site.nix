# SPDX-FileNotice: 🅭🄍1.0 This file is dedicated to the public domain using the CC0 1.0 Universal Public Domain Dedication <https://creativecommons.org/publicdomain/zero/1.0/>.
# SPDX-FileContributor: Jason Yundt <jason@jasonyundt.email> (2024)
#
# I want to contribute to GPG’s Web site [1]. GPG’s Web site’s build script [2]
# requires that your system is configured in a very specific way, or else it
# won’t work. This module makes sure that systems are capable of successfully
# running that script.
#
# [1]: <https://gnupg.org>
# [2]: <https://git.gnupg.org/cgi-bin/gitweb.cgi?p=gnupg-doc.git;a=blob;f=tools/build-website.sh;h=6e2842de4ce7dd7934754e7d64a9ec1573a1665c;hb=HEAD>
{ pkgs, config, lib, ... }:
let
	escape = lib.strings.escapeShellArg;
	chmodPath = "${pkgs.coreutils}/bin/chmod";
	chmodCmd = escape chmodPath;
	chownPath = "${pkgs.coreutils}/bin/chown";
	chownCmd = escape chownPath;
	userNames = [
		"webbuilder"
		"webbuild-x"
		"webbuild-y"
	];
	generateAndMerge = builderFunction: builderFunctionArgs: (
		builtins.listToAttrs (
			builtins.map builderFunction builderFunctionArgs
		)
	);
in {
	imports = [ ./caddy-dev-server.nix ];
	users = {
		groups.webbuilder = { };
		users = let
			webbuilderUser = userName: {
				name = userName;
				value = {
					createHome = true;
					group = "webbuilder";
					home = "/home/${userName}";
					isSystemUser = true;
				} // lib.attrsets.optionalAttrs (userName == "webbuilder") {
					homeMode = "755";
				};
			};
		in (generateAndMerge webbuilderUser userNames) // {
			# This makes sure that I have access to the folders in
			# ~webbuilder
			jayman.extraGroups = [ "webbuilder" ];
		};
	};
	home-manager.users = {
		jayman = { pkgs, ... }: {
			home.packages = let
				pkgCollections = import ../pkgCollections {
					inherit pkgs lib;
				};
				custom = pkgCollections.custom;
			in [ custom.start-shell-for-building-gnupg-doc ];
			# When you run build-website.sh [1], it will mess around
			# with Git repos that are owned by the webbuilder user.
			# As a result, if you run build-website.sh as jayman,
			# Git will detect that the directory is owned by a
			# different user, and then crash with this error:
			#
			# fatal: detected dubious ownership in repository at
			# '/home/webbuilder/gnupg-doc'
			#
			# The extraConfig that I’m adding here prevents that
			# error from happening.
			#
			# [1]: <https://git.gnupg.org/cgi-bin/gitweb.cgi?p=gnupg-doc.git;a=blob;f=tools/build-website.sh;h=6e2842de4ce7dd7934754e7d64a9ec1573a1665c;hb=HEAD>
			programs.git.extraConfig.safe = {
				directory = let
					users = config.users.users;
					webbuilderHome = users.webbuilder.home;
				in [
					"${webbuilderHome}/gnupg-doc"
					"${webbuilderHome}/gnupg-doc-preview"
				];
			};
		};
		webbuilder = { pkgs, lib, ... }: {
			home = let
				repoName = "gnupg-doc";
				internetRemote = let
					authority = "dev.gnupg.org";
					path = "/source/${repoName}.git";
				in "https://${authority}${path}";
				gnupg-docBaseRepo = pkgs.fetchgit {
					name = "${repoName}-base";
					url = internetRemote;
					rev = "0e84074653126b74ed085f2a33e512886c58faa4";
					hash = "sha256-g4cRTZKcspKd93o5iTOIU1fJj0IWv5+GLkPuexgFhQ8=";
					deepClone = true;
				};
			in {
				activation.gnupg-docRepo = let
					gitCmd = (
						(escape "${pkgs.git}/bin/git")
						+ " --no-pager"
					);
					cpCmd = escape "${pkgs.coreutils}/bin/cp";
					localRemote = let
						baseRepoPath = escape gnupg-docBaseRepo;
						defaultBranchName = "master";
						otherBranchName = "preview";
						otherBranchHash = "d50e44291126310b124b29767c55d0699f6b64de";
					in pkgs.runCommand "${repoName}-local-remote" { } ''
						${cpCmd} \
							--recursive \
							--no-preserve=mode \
							${baseRepoPath} \
							"$out"

						pushd "$out"
						${gitCmd} branch \
							--move \
							${escape defaultBranchName}
						${gitCmd} branch \
							${escape otherBranchName} \
							${escape otherBranchHash}
						popd
					'';
				in lib.hm.dag.entryAfter ["writeBoundary"] ''
					expected_origin=${escape "${internetRemote}"}
					readonly expected_origin
					function origin_has_correct_url {
						local actual
						actual="$(${gitCmd} config \
							remote.origin.url
						)"
						readonly actual

						[ "$actual" = "$expected_origin" ]
					}

					function branch_exists {
						${gitCmd} rev-parse \
							--verify \
							"$*" > /dev/null
					}

					if [ ! -d ~/gnupg-doc ]
					then
						$DRY_RUN_CMD ${gitCmd} clone \
							$VERBOSE_ARG \
							${escape "${localRemote}"} \
							~/gnupg-doc
					fi
					pushd ~/gnupg-doc
					if ! branch_exists preview
					then
						$DRY_RUN_CMD ${gitCmd} branch \
							--track	\
							preview \
							origin/preview
					fi
					popd
					if [ ! -d ~/gnupg-doc-preview ]
					then
						pushd ~/gnupg-doc
						$DRY_RUN_CMD ${gitCmd} worktree add \
							~/gnupg-doc-preview \
							preview
						popd
					fi
					pushd ~/gnupg-doc
					if ! origin_has_correct_url
					then
						$DRY_RUN_CMD ${gitCmd} remote \
							$VERBOSE_ARG \
							set-url \
								origin \
								"$expected_origin"
					fi
					popd
				'';
				file = let
					optionalString = lib.strings.optionalString;
					mkEmptyDir = {
						dirName,
						mode ? null,
						user ? null,
						group ? null
					}: {
						name = dirName;
						value = {
							# This is a workaround
							# for the fact that Home
							# Manager doesn’t have
							# an option for creating
							# an empty directory.
							target = "${dirName}/.empty";
							# This makes sure that
							# the onChange script
							# gets run every time.
							text = builtins.toString builtins.currentTime;
							onChange = let
								sudoPath = "${config.security.wrapperDir}/sudo";
								sudoCmd = escape sudoPath;
							in ''
								dir=~/${escape dirName}
							'' + optionalString (mode != null) ''
								${sudoCmd} ${chmodCmd} \
									${escape mode} \
									"$dir"
							'' + optionalString (user != null || group != null) ''
								${sudoCmd} ${chownCmd} \
									${escape "${user}:${group}"} \
									"$dir"
							'';
						};
					};
					mkXOrYDir = xOrY: (mkEmptyDir {
						dirName = "webbuild-${xOrY}";
						mode = "2775";
						user = "webbuild-${xOrY}";
						group = "webbuilder";

					});
					mkToolScript = scriptName: {
						name = scriptName;
						value = {
							source = "${gnupg-docBaseRepo}/tools/${scriptName}";
							target = "bin/${scriptName}";
						};
					};
				in (generateAndMerge mkEmptyDir [
					{
						dirName = "gnupg-doc-preview-stage";
						mode = "2775";
						user = "webbuild-y";
						group = "webbuilder";
					}
					{
						dirName = "gnupg-doc-stage";
						mode = "2775";
						user = "webbuild-x";
						group = "webbuilder";
					}
					{
						dirName = "log";
						# This allows the jayman user to
						# access ~webbuilder/log. Access
						# to that directory is required
						# for build-website.sh [1] to be
						# able to create a lock file.
						#
						# [1]: <https://git.gnupg.org/cgi-bin/gitweb.cgi?p=gnupg-doc.git;a=blob;f=tools/build-website.sh;h=6e2842de4ce7dd7934754e7d64a9ec1573a1665c;hb=HEAD>
						mode = "770";
					}
				]) // (generateAndMerge mkXOrYDir [
					"x"
					"y"
				]) // (generateAndMerge mkToolScript [
					# The requirement for these tool scripts
					# comes from this part of
					# build-web-site.sh:
					# <https://git.gnupg.org/cgi-bin/gitweb.cgi?p=gnupg-doc.git;a=blob;f=tools/build-website.sh;h=6e2842de4ce7dd7934754e7d64a9ec1573a1665c;hb=HEAD#l328>
					"trigger-website-build"
					"build-website.sh"
					"mkkudos.sh"
					"append-to-donors.sh"
				]);
				stateVersion = config.system.stateVersion;
			};
		};
	};
	security.sudo.extraRules = [
		{
			users = [ "webbuilder" ];
			commands = [
				{
					command = "${chmodPath} *";
					options = [ "NOPASSWD" ];
				}
				{
					command = "${chownPath} *";
					options = [ "NOPASSWD" ];
				}
			];
		}
	];
	systemd.tmpfiles.settings."gpg-web-site-www" = let
		fileProperties = mode: {
			inherit mode;
			group = "users";
			user = "jayman";
		};
		gpgWebSiteWWWDirName = subdomain: subdir: (
			"/var/www/www/${subdomain}.gnupg.org/${subdir}"
		);
		mkGpgWebSiteWWWDir = { subdomain, subdir }: {
			name = gpgWebSiteWWWDirName subdomain subdir;
			value = {
				d = fileProperties "700";
			};
		};
		argsForMkGpgWebSiteWWWDir = builtins.concatMap (subdir: [
			{ subdomain = "www"; inherit subdir; }
			{ subdomain = "preview"; inherit subdir; }
		]);
		wwwDonateDir = "${gpgWebSiteWWWDirName "www" "htdocs"}/donate";
		previewDonateDir = "${gpgWebSiteWWWDirName "preview" "htdocs"}/donate";
	in (generateAndMerge mkGpgWebSiteWWWDir (argsForMkGpgWebSiteWWWDir [
		"htdocs"
		"misc"
	])) // {
		# build-website.sh is supposed to automatically create these
		# file, but it doesn’t it only creates the one for the main www
		# htdocs directory. It doesn’t create one for the preview htdocs
		# directory.
		"${previewDonateDir}/donors.dat" = {
			f = fileProperties "600";
		};
		# build-website.sh needs these files in order to succeed, but
		# never tries to create them.
		"${previewDonateDir}/donations.dat" = {
			f = fileProperties "600";
		};
		"${wwwDonateDir}/donations.dat" = {
			f = fileProperties "600";
		};
		# Make sure that the directories for the previous files aren’t
		# owned by root.
		"${previewDonateDir}" = {
			d = fileProperties "700";
		};
		"${wwwDonateDir}" = {
			d = fileProperties "700";
		};
		# mkkudos.sh has one of its variables set incorrectly [1]. This
		# next item is a workaround for that problem.
		#
		# [1]: <https://git.gnupg.org/cgi-bin/gitweb.cgi?p=gnupg-doc.git;a=blob;f=tools/mkkudos.sh;h=f88b48bec214945e1628e903f358fc8125465163;hb=HEAD#l117>
		"${gpgWebSiteWWWDirName "blog" "htdocs"}" = {
			"L+" = (fileProperties "700") // {
				argument = let
					subdir = "misc/blog";
				in gpgWebSiteWWWDirName "www" subdir;
			};
		};
	};
}
