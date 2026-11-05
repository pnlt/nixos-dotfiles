# luisnquin's Hyprland, on the scrolling layout with niri's binds and rules.
# Hyprland 0.55+ reads hyprland.lua; bump wayland.windowManager.hyprland.package if yours is older.
args @ {
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.generators) mkLuaInline;

  tideCall = target: fn: "${lib.getExe pkgs.quickshell} ipc -p ${pkgs.tide-island}/share/tide-island call ${target} ${fn}";

  herdrHub = pkgs.writeShellScript "ghostty-herdr-hub" ''
    exec ${lib.getExe config.programs.ghostty.package} --class=ghostty.herdr \
      --keybind=clear \
      --keybind=super+shift+c=copy_to_clipboard \
      --keybind=super+shift+v=paste_from_clipboard \
      --keybind=ctrl+shift+v=paste_from_clipboard \
      '--keybind=shift+enter=text:\x1b\r' \
      -e ${lib.getExe pkgs.herdr} --session hub
  '';

  herdrDrop = import ./drop.nix {inherit pkgs lib;} {
    name = "ghostty-herdr";
    class = "ghostty.herdr";
    command = toString herdrHub;
    width = 1800;
    height = 1000;
  };

  allowExe = exe: type: {_args = [(lib.escapeRegex exe) type "allow"];};

  xdph = "${pkgs.xdg-desktop-portal-hyprland}/libexec/xdg-desktop-portal-hyprland";

  floatingDialog = class: {
    name = "dialog-${class}";
    match.class = "^${lib.escapeRegex class}$";
    float = true;
    size = "monitor_w*0.45 monitor_h*0.45";
    center = true;
  };
in {
  imports = [./tide-island.nix];

  home.sessionVariables.GRIMBLAST_HIDE_CURSOR = 0;

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    portalPackage = null;
    # niri-session imports the whole login environment too; services such as
    # tide-island launch apps that only live on the home-manager PATH.
    systemd.variables = ["--all"];

    settings = {
      monitor = [
        {
          output = "DP-2";
          mode = "2560x1440@200";
          position = "0x0";
          scale = 1.25;
        }
        {
          output = "HDMI-A-1";
          mode = "1920x1080@74.97";
          position = "2048x0";
          scale = 1;
          transform = 1;
        }
        {
          output = "";
          mode = "preferred";
          position = "auto-right";
          scale = 1;
        }
      ];

      config = {
        general = {
          layout = "scrolling";
          gaps_in = 4;
          gaps_out = 20;
          border_size = 1;
          col = {
            active_border = "rgba(595959aa)";
            inactive_border = "rgba(595959aa)";
          };
        };

        decoration = {
          rounding = 4;
          blur = {
            enabled = true;
            size = 3;
            passes = 1;
          };
          active_opacity = 0.9;
          inactive_opacity = 1.0;
          fullscreen_opacity = 1.0;
          shadow = {
            enabled = true;
            range = 4;
            render_power = 3;
            color = "rgba(1a1a1aee)";
          };
        };

        debug = {
          disable_logs = true;
        };

        animations = {
          enabled = true;
        };

        input = {
          kb_layout = "us";
          numlock_by_default = true;
          repeat_delay = 200;
          repeat_rate = 25;
          accel_profile = "flat";
          follow_mouse = 1;
        };

        cursor = {
          no_warps = true;
          hide_on_key_press = true;
          inactive_timeout = 10;
        };

        binds = {
          workspace_back_and_forth = true;
        };

        misc = {
          disable_autoreload = true;
          disable_hyprland_logo = true;
          focus_on_activate = false;
          initial_workspace_tracking = 0;
          middle_click_paste = false;
          vrr = 3;
        };

        render = {
          direct_scanout = 2;
        };

        scrolling = {
          column_width = 0.5;
          fullscreen_on_one_column = true;
          focus_fit_method = 1;
          explicit_column_widths = "0.333, 0.5, 0.667, 1.0";
          direction = "right";
        };

        ecosystem = {
          no_update_news = true;
          enforce_permissions = true;
        };
      };

      curve = [
        {
          _args = [
            "myBezier"
            {
              type = "bezier";
              points = [
                [0.05 0.9]
                [0.1 1.05]
              ];
            }
          ];
        }
      ];

      animation = [
        {
          leaf = "windows";
          enabled = true;
          speed = 7;
          bezier = "myBezier";
        }
        {
          leaf = "windowsOut";
          enabled = true;
          speed = 7;
          bezier = "default";
          style = "popin 80%";
        }
        {
          leaf = "border";
          enabled = true;
          speed = 10;
          bezier = "default";
        }
        {
          leaf = "borderangle";
          enabled = true;
          speed = 8;
          bezier = "default";
        }
        {
          leaf = "fade";
          enabled = true;
          speed = 7;
          bezier = "default";
        }
        {
          leaf = "workspaces";
          enabled = true;
          speed = 6;
          bezier = "default";
        }
      ];

      workspace_rule = [
        {
          workspace = "name:music";
          monitor = "HDMI-A-1";
        }
      ];

      window_rule =
        [
          {
            name = "open-maximized";
            match = {class = "^(zen-beta|calibre-gui)$";};
            scrolling_width = 1.0;
          }
          {
            name = "pip";
            match = {title = "^(Picture in picture|Picture-in-Picture)$";};
            size = "640 360";
            float = true;
            pin = true;
            no_initial_focus = true;
          }
          {
            name = "bitwarden-extension";
            match = {title = ".*Extension.*Bitwarden.*";};
            float = true;
            center = true;
          }
          {
            name = "emulator-opacity";
            match = {class = "^Emulator$";};
            opacity = "1.0 override 1.0 override 1.0 override";
          }
          {
            name = "android-emulator-float";
            match = {title = "^(Android Emulator -)";};
            float = true;
          }
          {
            name = "waybar-nmtui";
            match = {class = "^waybar\\.nmtui$";};
            float = true;
            size = "1050 720";
            center = true;
          }
          {
            name = "btop";
            match = {class = "^ghostty\\.btop$";};
            float = true;
            size = "monitor_w*0.95 monitor_h*0.8";
            center = true;
          }
          {
            name = "dev-terminal";
            match = {class = "^dev\\.terminal$";};
            workspace = "name:dev";
            scrolling_width = 1.0;
          }
          {
            name = "drift";
            match = {class = "^ghostty\\.drift$";};
            workspace = "name:music";
            scrolling_width = 1.0;
          }
          herdrDrop.windowRule
          {
            name = "steam-xwayland-fake-fullscreen";
            match = {
              class = "^steam_app_[0-9]+$";
              xwayland = true;
              fullscreen_state_client = 2;
            };
            fullscreen_state = "2 0";
            suppress_event = "fullscreen fullscreenoutput";
            content = "game";
            idle_inhibit = "fullscreen";
          }
          {
            name = "color-picker-float";
            match = {
              class = "^(zenity|org\\.gnome\\.Zenity)$";
              title = "^Copy color to Clipboard$";
            };
            float = true;
            center = true;
          }
        ]
        ++ map floatingDialog [
          "confirm"
          "pavucontrol"
          "nm-connection-editor"
          "org.gnome.PowerStats"
          "cpupower"
          "easyeffects"
          "Hello"
          "xdg-desktop-portal-gtk"
          "ghostty_journalctl"
          "brave-keep"
        ];

      # Unlisted clients get an allow/deny prompt
      permission = [
        (allowExe (lib.getExe pkgs.grim) "screencopy")
        (allowExe xdph "screencopy")
        (allowExe xdph "cursorpos")
        # Tide's overview window previews
        (allowExe "${pkgs.quickshell}/bin/.quickshell-wrapped" "screencopy")
      ];

      bind = import ./binds.nix (args // {inherit herdrDrop tideCall;});

      on = [
        {
          _args = [
            "hyprland.start"
            (mkLuaInline ''
              function()
                hl.exec_cmd("${pkgs.easyeffects}/bin/easyeffects --gapplication-service")
                ${herdrDrop.startupBody}
              end
            '')
          ];
        }
      ];
    };
  };
}
