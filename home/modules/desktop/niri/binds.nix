{
  config,
  pkgs,
  lib,
  ...
}: let
  home = config.home.homeDirectory;
  ghostty = lib.getExe config.programs.ghostty.package;
  fuzzel = lib.getExe pkgs.fuzzel;
  nautilus = lib.getExe pkgs.nautilus;
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  makoctl = "${pkgs.mako}/bin/makoctl";
  playerctl = lib.getExe pkgs.playerctl;
  devScript = "${home}/nixos-dotfiles/config/niri/scripts/dev";

  clipMenu = pkgs.writeShellScript "niri-cliphist-fuzzel" ''
    set -euo pipefail
    ${pkgs.cliphist}/bin/cliphist list \
      | ${fuzzel} --dmenu \
      | ${pkgs.cliphist}/bin/cliphist decode \
      | ${pkgs.wl-clipboard}/bin/wl-copy
  '';

  powerMenu = pkgs.writeShellScript "niri-power-menu" ''
    set -euo pipefail
    entry=$(printf 'Lock\nLogout\nSuspend\nReboot\nShutdown' | ${fuzzel} --dmenu -p 'Power: ')
    case "$entry" in
      Lock) loginctl lock-session ;;
      Logout) niri msg action quit --skip-confirmation ;;
      Suspend) systemctl suspend ;;
      Reboot) systemctl reboot ;;
      Shutdown) systemctl poweroff ;;
    esac
  '';
in ''
  binds {
      Mod+Return     { spawn "${ghostty}"; }
      Mod+Alt+Return { spawn "${devScript}"; }

      // was dms clipboard
      Mod+Alt+V { spawn "${clipMenu}"; }

      // was dms notifications — focus/show mako history
      Mod+N { spawn "${makoctl}" "history"; }

      // was dms spotlight → fuzzel
      Mod+D { spawn "${lib.getExe pkgs.fuzzel}"; }
      Mod+Space { spawn "${lib.getExe pkgs.raffi}"; }

      // was dms powermenu
      Mod+X { spawn "${powerMenu}"; }

      Mod+Shift+S { screenshot show-pointer=false; }
      Print       { screenshot show-pointer=false; }

      Mod+E { spawn "${nautilus}" "--new-window"; }
      Mod+Z { spawn "zen-beta"; }

      // was dms mpris
      XF86Launch3 { spawn "${playerctl}" "play-pause"; }

      // was dms audio → wpctl
      XF86AudioLowerVolume allow-when-locked=true {
          spawn "${wpctl}" "set-volume" "@DEFAULT_AUDIO_SINK@" "3%-";
      }
      XF86AudioRaiseVolume allow-when-locked=true {
          spawn "${wpctl}" "set-volume" "@DEFAULT_AUDIO_SINK@" "3%+";
      }
      XF86AudioMute allow-when-locked=true {
          spawn "${wpctl}" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
      }
      XF86AudioMicMute allow-when-locked=true {
          spawn "${wpctl}" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle";
      }

      Mod+O repeat=false { toggle-overview; }
      Mod+Q repeat=false { close-window; }

      Mod+H { focus-column-left; }
      Mod+J { focus-window-or-workspace-down; }
      Mod+K { focus-window-or-workspace-up; }
      Mod+L { focus-column-right; }

      Mod+Alt+H { move-column-left; }
      Mod+Alt+J { move-window-down-or-to-workspace-down; }
      Mod+Alt+K { move-window-up-or-to-workspace-up; }
      Mod+Alt+L { move-column-right; }

      Mod+Left  { focus-column-first; }
      Mod+Right { focus-column-last; }
      Mod+Alt+Left  { move-column-to-first; }
      Mod+Alt+Right { move-column-to-last; }

      Mod+1 { focus-workspace 1; }
      Mod+2 { focus-workspace 2; }
      Mod+3 { focus-workspace 3; }
      Mod+4 { focus-workspace 4; }
      Mod+5 { focus-workspace 5; }
      Mod+6 { focus-workspace 6; }
      Mod+7 { focus-workspace 7; }
      Mod+8 { focus-workspace 8; }
      Mod+9 { focus-workspace 9; }

      Mod+Alt+1 { move-column-to-workspace 1; }
      Mod+Alt+2 { move-column-to-workspace 2; }
      Mod+Alt+3 { move-column-to-workspace 3; }
      Mod+Alt+4 { move-column-to-workspace 4; }
      Mod+Alt+5 { move-column-to-workspace 5; }
      Mod+Alt+6 { move-column-to-workspace 6; }
      Mod+Alt+7 { move-column-to-workspace 7; }
      Mod+Alt+8 { move-column-to-workspace 8; }
      Mod+Alt+9 { move-column-to-workspace 9; }

      Mod+Comma  { consume-or-expel-window-left; }
      Mod+Period { consume-or-expel-window-right; }

      Mod+R { switch-preset-column-width; }
      Mod+M { maximize-column; }
      Mod+Alt+M { expand-column-to-available-width; }
      Mod+F { fullscreen-window; }
      Mod+C { center-column; }
      Mod+Alt+C { center-visible-columns; }
      Mod+Minus { set-column-width "-10%"; }
      Mod+equal { set-column-width "+10%"; }
      Mod+Alt+Minus { set-window-height "-10%"; }
      Mod+Alt+equal { set-window-height "+10%"; }
      Mod+T { toggle-window-floating; }
      Mod+Alt+T { switch-focus-between-floating-and-tiling; }
      Mod+W { toggle-column-tabbed-display; }
      Mod+Shift+W { spawn "wallpaper-next"; }

      Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }
  }
''
