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
      search.default = "ddg";
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
        };
      };
    };
}
