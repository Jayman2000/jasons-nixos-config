# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2025 Jason Yundt <jason@jasonyundt.email>
/**
  Configures any Web browsers that the system uses.
*/
{ inputs, ... }:
{
  config,
  pkgs,
  ...
}:
{
  programs.firefox = {
    enable = true;
    languagePacks = [ "en-US" ];
    profiles."${config.home.username}" = {
      extensions.packages =
        let
          system = pkgs.hostPlatform.system;
          nurRepos = inputs.nur.legacyPackages."${system}".repos;
        in
        [
          nurRepos.rycee.firefox-addons.ublock-origin
        ];
      isDefault = true;
      search = {
        default = "ddg";
        # Every so often, I get errors about potentially clobbering a
        # search-related Firefox configuration file when I switch to a
        # new Home Manager generation. Hopefully, setting force to true
        # will prevent that from happening.
        force = true;
      };
      settings = {
        "browser.newtabpage.enabled" = false;
        "browser.search.suggest.enabled" = false;
        "browser.startup.homepage" = "about:blank";
        # This next part customizes the toolbar.
        "browser.uiCustomization.state" = ''
          {
            "placements": {
              "widget-overflow-fixed-list": [],
              "unified-extensions-area": [],
              "nav-bar": [
                "back-button",
                "forward-button",
                "stop-reload-button",
                "vertical-spacer",
                "urlbar-container",
                "search-container",
                "downloads-button",
                "ublock0_raymondhill_net-browser-action",
                "unified-extensions-button"
              ],
              "toolbar-menubar": [
                "menubar-items"
              ],
              "TabsToolbar": [
                "firefox-view-button",
                "tabbrowser-tabs",
                "new-tab-button",
                "alltabs-button"
              ],
              "vertical-tabs": [],
              "PersonalToolbar": [
                "import-button",
                "personal-bookmarks"
              ]
            },
            "seen": [
              "save-to-pocket-button",
              "ublock0_raymondhill_net-browser-action",
              "developer-button"
            ],
            "dirtyAreaCache": [
              "unified-extensions-area",
              "nav-bar",
              "vertical-tabs",
              "PersonalToolbar"
            ],
            "currentVersion": 22,
            "newElementCount": 7
          }
        '';
        "dom.security.https_only_mode" = true;
        # Without this, declaratively configured extensions would be
        # automatically installed, but they wouldn’t be enabled
        # automatically.
        "extensions.autoDisableScopes" = 0;
      };
    };
    policies.OverrideFirstRunPage = "";
  };
  # See
  # <https://github.com/gorhill/uBlock/wiki/Deploying-uBlock-Origin>.
  home.file.ublockOriginConfig =
    let
      extensionName = "uBlock0@raymondhill.net";
    in
    {
      target = ".mozilla/managed-storage/${extensionName}.json";
      text = builtins.toJSON {
        name = extensionName;
        description = "Declarative configuration for uBlock Origin";
        type = "storage";
        data = {
          userSettings = [
            [
              "autoUpdate"
              "false"
            ]
          ];
          # adminSettings is deprecated [1], but it’s the only way to
          # turn on uBlock Origin’s “Disable JavaScript” feature [2].
          #
          # editorconfig-checker-disable
          # [1]: <https://github.com/gorhill/uBlock/wiki/Deploying-uBlock-Origin#customizing-the-settings>
          # [2]: <https://github.com/uBlockOrigin/uBlock-issues/discussions/3694>
          # editorconfig-checker-enable
          adminSettings = {
            hostnameSwitchesString = ''
              ${
                # These first two are set by uBlock Origin by default.
                ""
              }
              no-large-media: behind-the-scene false
              no-csp-reports: * true
              ${
                # This one disables JavaScript.
                ""
              }
              no-scripting: * true
              ${
                # This next part allows JavaScript on certain Web sites.
                ""
              }
              no-scripting: search.nixos.org false
            '';
          };
        };
      };
    };
}
