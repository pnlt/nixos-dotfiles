{inputs, ...}: {
  flake.modules.homeManager.browser = {
    pkgs,
    lib,
    ...
  }: {
    imports = [
      inputs.zen-browser.homeModules.beta
    ];

    programs.zen-browser = {
      enable = true;
      languagePacks = ["en-US"];
      policies = import ./_policies-config.nix;
      setAsDefaultBrowser = true;
      enablePrivateDesktopEntry = true;

      profiles.default = rec {
        settings = {
          "zen.workspaces.continue-where-left-off" = true;
          "zen.workspaces.natural-scroll" = true;
          "zen.view.compact.hide-tabbar" = true;
          "zen.view.compact.hide-toolbar" = true;
          "zen.view.compact.animate-sidebar" = false;
          "zen.welcome-screen.seen" = true;
          "zen.urlbar.behavior" = "float";
          "zen.theme.hide-unified-extensions-button" = true;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

          # marionette sets this to true and only clears it on a clean shutdown;
          # left on, gecko fakes window focus and dead keys stop composing (á, ñ)
          "focusmanager.testmode" = false;

          "dom.webmidi.enabled" = false;

          # "<site> wants to access other apps and services on this device" is the
          # local network access prompt (loopback-network/local-network), not WebMIDI;
          # shops like aliexpress port-scan 127.0.0.1 to fingerprint. 2 = BLOCK, and
          # PermissionUI cancels the request instead of drawing a doorhanger.
          "permissions.default.loopback-network" = 2;
          "permissions.default.local-network" = 2;
        };

        presets.betterfox.enable = true;

        extensions.settings."{74145f27-f039-47ce-a470-a662b129930a}" = {
          force = true;
          settings = {
            badged_color = "#7b383a";
            badgedStatus = true;
            domainBlocking = false;
            eTagFiltering = true;
            hashURL = "https://rules2.clearurls.xyz/rules.minify.hash";
            # replaceState-rewrites Google OAuth consent URLs mid-flow, consent then 400s
            historyListenerEnabled = false;
            localHostsSkipping = true;
            logLimit = 250;
            loggingStatus = true;
            pingBlocking = true;
            referralMarketing = true;
            ruleURL = "https://rules2.clearurls.xyz/data.minify.json";
            statisticsStatus = true;
          };
        };
        extensions.settings."vimium-c@gdh1995.cn" = {
          force = true;
          settings = {
            vimSync = false;
            # stop pages from stealing focus into an input on load, so keys work at once
            grabBackFocus = true;
            userDefinedCss = lib.concatMapStrings (s: "/* #${s} */\n" + builtins.readFile ./vimium-c/${s}.css) ["ui" "find" "omni"];
            # <c-e>/<c-y> clash with zen's Ctrl+E compact mode; J/K walk the vertical tab list
            keyMappings = ''
              unmap <c-e>
              unmap <c-y>
              map J nextTab
              map K previousTab
            '';
            searchEngines = ''
              g|google: https://www.google.com/search?q=%s Google
              d|ddg: https://duckduckgo.com/?q=%s DuckDuckGo
              y|yt: https://www.youtube.com/results?search_query=%s YouTube
              w|wiki: https://en.wikipedia.org/w/index.php?search=%s Wikipedia
              gh: https://github.com/search?q=%s&type=repositories GitHub
              np: https://search.nixos.org/packages?channel=unstable&query=%s Nix Packages
              no: https://search.nixos.org/options?channel=unstable&query=%s Nix Options
              hm: https://home-manager-options.extranix.com/?release=master&query=%s Home Manager
              gm: https://www.google.com/maps?q=%s Google Maps
            '';
          };
        };
        extensionButtons = {
          "nav-bar" = ["uBlock0@raymondhill.net"];
        };

        bookmarks = import ./_bookmarks-config.nix {
          inherit lib;
          libx = import ../../../../lib {inherit pkgs;};
        };
        search = import ./_search-config.nix {inherit pkgs;};
        userContent = import ./_user-content-config.nix {inherit pkgs lib;};

        sine = {
          enable = true;
          mods = [
            "253a3a74-0cc4-47b7-8b82-996a64f030d5" # Floating History
            "4ab93b88-151c-451b-a1b7-a1e0e28fa7f8" # No Sidebar Scrollbar
            "7190e4e9-bead-4b40-8f57-95d852ddc941" # Tab title fixes
            "803c7895-b39b-458e-84f8-a521f4d7a064" # Hide Inactive Workspaces
            "906c6915-5677-48ff-9bfc-096a02a72379" # Floating Status Bar
            "a6335949-4465-4b71-926c-4a52d34bc9c0" # Better Find Bar
            "c6813222-6571-4ba6-8faf-58f3343324f6" # Disable Rounded Corners
            "c8d9e6e6-e702-4e15-8972-3596e57cf398" # Zen Back Forward
            "cb15abdb-0514-4e09-8ce5-722cf1f4a20f" # Hide Extension Name
            "d8b79d4a-6cba-4495-9ff6-d6d30b0e94fe" # Better Active Tab
            "e122b5d9-d385-4bf8-9971-e137809097d0" # No Top Sites
            "1b88a6d1-d931-45e8-b6c3-bfdca2c7e9d6" # Remove Tab X
            "f7c71d9a-bce2-420f-ae44-a64bd92975ab" # Better Unloaded Tabs
            "fd24f832-a2e6-4ce9-8b19-7aa888eb7f8e" # Quietify
            "context-menu-icons"
          ];
        };

        spaceRouting.defaultExternalRoute = spaces."Development".id;

        pinsForce = true;
        pinsForceAction = "demote";
        pins = {
          "Telegram Web" = {
            id = "5065293b-1c04-40ee-ba1d-99a231873864";
            url = "https://web.telegram.org/k/";
            isEssential = true;
          };
          "Hacker News" = {
            id = "c90aabb4-0e7b-48a8-85a8-5245ea84f095";
            url = "https://news.ycombinator.com/";
            isEssential = true;
          };
        };

        joinedTabs."Inside state" = let
          state = spaces."Development".pins."State";
        in {
          id = "inside-state";
          gridType = "vsep";
          folderParentId = state.id;
          tabs = [
            state.pins."Cursor".id
            state.pins."Codex".id
            state.pins."Claude".id
          ];
        };

        containersForce = true;

        spacesForce = true;
        spaces = {
          "Development" = {
            id = "572910e1-4468-4832-a869-0b3a93e2f165";
            icon = "chrome://browser/skin/zen-icons/selectable/navigate.svg";
            position = 1000;
            pins = {
              "GitHub" = {
                id = "48e8a119-5a14-4826-9545-91c8e8dd3bf6";
                url = "https://github.com";
                position = 101;
              };

              "State" = {
                id = "482bc905-c00c-4c49-8a56-367668bf70b9";
                folderIcon = "chrome://browser/skin/zen-icons/selectable/eye.svg";
                isGroup = true;
                isFolderCollapsed = true;
                editedTitle = true;
                position = 200;

                pins = {
                  "Cursor" = {
                    id = "384413fa-89aa-408c-b7bb-260e49dea3d3";
                    url = "https://cursor.com/dashboard/spending";
                    position = 201;
                    editedTitle = true;
                    title = "Cursor Usage";
                  };
                  "Codex" = {
                    id = "0dc25f8f-a801-46ed-853b-6d866622bc18";
                    url = "https://chatgpt.com/codex/cloud/settings/analytics#usage";
                    position = 201;
                    editedTitle = true;
                    title = "Codex Usage";
                  };
                  "Claude" = {
                    id = "b9852a90-794e-4692-989b-bd2fb376bc54";
                    url = "https://platform.claude.com/usage";
                    position = 201;
                    editedTitle = true;
                    title = "Claude Usage";
                  };
                  "Tailscale" = {
                    id = "4398f631-714c-450f-9b10-eb69ab27244a";
                    url = "https://login.tailscale.com/admin/machines";
                    position = 153;
                  };
                };
              };
            };

            liveFolders = {};

            routes = {
              "GitHub" = {
                reference = "github.com";
                matchType = "equal-to";
              };

              "Tailscale".reference = "tailscale.com";
            };

            theme = {
              type = "gradient";
              colors = [
                {
                  red = 14;
                  green = 14;
                  blue = 14;
                  algorithm = "floating";
                  type = "explicit-lightness";
                  lightness = 6;
                  primary = true;
                  custom = false;
                }
              ];
              opacity = 0.8;
              texture = 0.0;
            };
          };
          "Research" = {
            id = "ec287d7f-d910-4860-b400-513f269dee77";
            icon = "chrome://browser/skin/zen-icons/selectable/logo-rss.svg";
            position = 1001;
            theme = {
              type = "gradient";
              colors = [
                {
                  red = 171;
                  green = 219;
                  blue = 227;
                  algorithm = "floating";
                  type = "explicit-lightness";
                }
              ];
              opacity = 0.2;
              texture = 0.5;
            };
          };
          "Music" = {
            id = "7d93eccc-121c-45df-9d45-48cc001b4f64";
            icon = "chrome://browser/skin/zen-icons/selectable/music.svg";
            position = 1002;
          };
        };

        keyboardShortcutsVersion = 21;
        keyboardShortcuts =
          [
            {
              id = "zen-compact-mode-toggle";
              key = "e";
              modifiers.control = true;
            }
          ]
          ++ map (n: {
            id = "zen-workspace-switch-${n}";
            key = n;
            modifiers.control = true;
          }) ["1" "2" "3"]
          ++ map (id: {
            inherit id;
            disabled = true;
          }) [
            "zen-compact-mode-show-sidebar"
            "key_savePage"
            "key_quitApplication"
            "zen-copy-url"
            "addBookmarkAsKb"

            # vimium c owns these: H/L, r, /, x, X, T
            "goBackKb"
            "goForwardKb"
            "key_reload"
            "key_reload_skip_cache"
            "key_search"
            "key_find"

            "key_close"
            "key_restoreLastClosedTabOrWindowOrSession"
            "key_selectTab1"
            "key_selectTab2"
            "key_selectTab3"
            "key_selectTab4"
            "key_selectTab5"
            "key_selectTab6"
            "key_selectTab7"
            "key_selectTab8"
            "key_selectLastTab"

            "zen-workspace-forward"
            "zen-workspace-backward"
            "zen-library-toggle"
            "zen-new-unsynced-window"
            "zen-glance-expand"
            "zen-toggle-pin-tab"
            "zen-copy-url-markdown"
            "key_closeWindow"
            "goBackKb2"
            "goForwardKb2"
            "key_search2"
            "key_findAgain"
            "key_findPrevious"
            "key_findAgain2"
            "key_findPrevious2"

            "focusURLBar"
            "focusURLBar2"
            "printKb"
            "key_toggleReaderMode"
            "key_togglePictureInPicture"
            "key_viewSource"
            "key_viewInfo"

            "showAllHistoryKb"
            "manBookmarkKb"

            "key_toggleMute"
            "key_fullZoomReduce"
            "key_fullZoomEnlarge"
            "key_fullZoomReset"
            "key_switchTextDirection"
            "key_screenshot"

            "key_toggleToolbox"
            "key_browserToolbox"
            "key_browserConsole"
            "key_responsiveDesignMode"
            "key_inspector"
            "key_webconsole"
            "key_jsdebugger"
            "key_netmonitor"
            "key_styleeditor"
            "key_performance"
            "key_storage"
            "key_dom"
            "key_accessibility"

            "key_openDownloads"
            "key_openAddons"
            "key_delete"
            "key_reload2"
            "key_reload_skip_cache2"
            "key_enterFullScreen"
            "key_exitFullScreen"
            "key_aboutProcesses"
            "viewBookmarksSidebarKb"
            "viewBookmarksToolbarKb"
            "viewGenaiChatSidebarKb"
            "toggleSidebarKb"
            "key_showAllTabs"
            "key_sanitize"
            "key_wrCaptureCmd"
            "key_wrToggleCaptureSequenceCmd"
          ];
      };
    };
  };
}
