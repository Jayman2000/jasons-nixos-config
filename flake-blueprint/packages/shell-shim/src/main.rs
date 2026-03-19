// SPDX-License-Identifier: CC0-1.0
// SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
use std::env;
use std::ffi::{OsStr, OsString};
use std::os::unix::ffi::OsStringExt;
use std::os::unix::process::CommandExt;
use std::path::Path;
use std::process::Command;
use std::str;

use shell_quote::Bash;

fn main() {
    const BASH_PATH: &'static str = env!("bashPath");
    const DESIRED_SHELL_PATH: &'static str = env!("desiredShellPath");
    const UTF8_HYPHEN_MINUS: u8 = "-".as_bytes()[0];
    const ZERO_ARG_ERROR: &str = "This program was run with zero \
        command-line arguments (not even argv[0]).";
    const NO_FILE_NAME_ERROR: &str = "When this program was built, the \
        bashPath environment variable was set to a path that doesn’t \
        end with a file name.";

    let mut args_iterator = env::args_os();
    let my_arg0 = args_iterator.next().expect(ZERO_ARG_ERROR);
    // See <https://unix.stackexchange.com/a/78096/316181>.
    let is_login_shell = my_arg0.into_vec()[0] == UTF8_HYPHEN_MINUS;

    let mut command = Command::new(BASH_PATH);
    if is_login_shell {
        let mut arg0: OsString = OsStr::new("-").into();
        let name =
            Path::new(BASH_PATH).file_name().expect(NO_FILE_NAME_ERROR);
        arg0.push(name);
        command.arg0(arg0);
    }
    command.args(args_iterator);
    if command.get_args().len() == 0 {
        let desired_shell_command_bytes =
            Bash::quote_vec(DESIRED_SHELL_PATH);
        let mut desired_shell_command: String =
            str::from_utf8(&desired_shell_command_bytes)
                .expect("Invalid UTF-8")
                .to_owned();
        if is_login_shell {
            desired_shell_command.push_str(" --login");
        }
        command.args(["-c", &desired_shell_command]);
    }
    let error = command.exec();
    println!(
        "Encountered error {error:?} while trying to run {command:?}."
    );
}

#[cfg(test)]
mod tests {
    use super::*;

    use cargo::core::SourceId;
    use cargo::core::features::Edition;
    use cargo::core::manifest::EitherManifest;
    use cargo::util::context::GlobalContext;
    use cargo::util::toml;

    #[test]
    fn latest_rust_edition() {
        let manifest_path = Path::new(env!("CARGO_MANIFEST_PATH"));
        let source_id = SourceId::for_path(manifest_path)
            .expect("Failed to create a SourceId");
        let global_context = GlobalContext::default()
            .expect("Failed to get default GlobalContext.");
        let either_manifest = toml::read_manifest(
            manifest_path,
            source_id,
            &global_context,
        )
        .expect("Failed to read manifest.");
        let manifest = match either_manifest {
            EitherManifest::Real(manifest) => manifest,
            EitherManifest::Virtual(_) => {
                panic!(
                    "VirtualManifests are not supported at the moment."
                )
            }
        };
        assert_eq!(
            manifest.edition(),
            Edition::LATEST_STABLE,
            "This crate isn’t using the latest stable Rust edition. \
                Current edition: {}. Latest edition: {}",
            manifest.edition(),
            Edition::LATEST_STABLE
        );
    }
}
