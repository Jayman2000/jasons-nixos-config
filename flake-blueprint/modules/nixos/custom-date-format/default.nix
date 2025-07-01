# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
/**
  This module enables a custom locale that uses ISO 8601-style dates.
*/
{
  config,
  lib,
  options,
  ...
}:
{
  i18n =
    let
      inherit (lib.strings) escapeShellArg;
      localeLangAndTerritory = "en_US";
      localeCodeset = "UTF-8";
      customLocaleModifier = "jason";
      # See section 7.6 of the GNU C Library manual [1].
      #
      # editorconfig-checker-disable
      # [1]: <https://sourceware.org/glibc/manual/2.41/html_node/Locale-Names.html>
      # editorconfig-checker-enable
      baseLocale = "${localeLangAndTerritory}.${localeCodeset}";
      customLocale = "${baseLocale}@${customLocaleModifier}";

      defaultGlibcLocales = options.i18n.glibcLocales.default;
      overrideAttrsFunction = finalAttrs: previousAttrs: {
        env.patchFile = "${./0001-Use-ISO-8601-date-format.patch}";
        postUnpack =
          (previousAttrs.postUnpack or "")
          + ''
            readonly locales_dir="$sourceRoot/localedata/locales"
            # editorconfig-checker-disable
            readonly original="$locales_dir/"${escapeShellArg localeLangAndTerritory}
            readonly new="$locales_dir/"${escapeShellArg "${localeLangAndTerritory}@${customLocaleModifier}"}
            # editorconfig-checker-enable
            cp "$original" "$new"
            # The --strip=1 part is needed to apply patches that were
            # generated using git-format-patch [1].
            #
            # editorconfig-checker-disable
            # [1]: <https://old.reddit.com/r/git/comments/m1sw8a/apply_patch_files_to_non_git_repo>
            # editorconfig-checker-enable
            patch \
              --strip=1 \
              --input="$patchFile" \
              --directory="$sourceRoot"
            # Without this next part, this package would fail to build.
            printf \
              '%s\n' \
              ${escapeShellArg "${customLocale}/${localeCodeset} \\"} \
              >> "$sourceRoot/localedata/SUPPORTED"
          '';
      };
      # editorconfig-checker-disable
      customizedGlibcLocales = defaultGlibcLocales.overrideAttrs overrideAttrsFunction;
      # editorconfig-checker-enable
    in
    {
      # Originally, I had set defaultLocale to customLocale. This caused
      # Plasma 6’s Reigon & Language settings menu to display this
      # error:
      #
      # > The language "en_US@jason" is unsupported
      #
      # Hopefully, I’ll be able to avoid problems like that one by only
      # setting LC_TIME to customLocale.
      defaultLocale = baseLocale;
      extraLocaleSettings = {
        LC_TIME = customLocale;
      };
      glibcLocales = customizedGlibcLocales;
    };
}
