# https://wiki.hypr.land/Configuring/Basics/Binds/
# Keys follow niri's binds.nix; actions map onto the scrolling layout.
{
  config,
  pkgs,
  lib,
  herdrDrop,
  ...
}: let
  inherit (lib.generators) mkLuaInline;

  toLua' = lib.generators.toLua {};

  mainMod = "SUPER";
  hyprctlCmd = "${config.wayland.windowManager.hyprland.finalPackage}/bin/hyprctl";
  ghostty = lib.getExe config.programs.ghostty.package;
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  playerctl = lib.getExe pkgs.playerctl;
  vicinaeCmd = lib.getExe' config.programs.vicinae.package "vicinae";
  hex = lib.getExe config.programs.hex.package;
  hyprstfu = lib.getExe pkgs.hyprstfu;

  # `deeplink` only opens; it never closes an already-open window like `toggle` does.
  vicinaeApps = pkgs.writeShellScript "vicinae-apps-toggle" ''
    if ${vicinaeCmd} state open; then
      exec ${vicinaeCmd} close
    fi
    exec ${vicinaeCmd} deeplink vicinae://launch/applications
  '';

  grimblastCmd = let
    package = pkgs.grimblast.overrideAttrs (_oldAttrs: {
      prePatch = ''
        substituteInPlace ./grimblast --replace '-t 3000' '-t 3000 -i ${./crop.512.png}'
      '';
    });
  in
    lib.getExe package;

  hyprPrintScreen = let
    askTargetCmd = "${lib.getExe pkgs.hyprshot} -m output --clipboard-only";
    allTargetsCmd = "${grimblastCmd} --notify copy screen";
    evalCmd = "${hyprctlCmd} monitors all -j | ${lib.getExe pkgs.jq} \". | length\"";
  in
    pkgs.writeShellScript "hypr-print-screen" ''
      if [ "$(${evalCmd})" -eq 1 ]; then
        exec ${allTargetsCmd}
      else
        exec ${askTargetCmd}
      fi
    '';

  powerMenu = pkgs.writeShellScript "power-menu" ''
    case "$(printf '%s\n' Poweroff Reboot Logout | ${vicinaeCmd} dmenu -n Power --no-section --no-footer)" in
      Poweroff) systemctl poweroff ;;
      Reboot) systemctl reboot ;;
      Logout) ${hyprctlCmd} dispatch 'hl.dsp.exit()' ;;
    esac
  '';

  dspExec = cmd: mkLuaInline ("hl.dsp.exec_cmd(" + toLua' cmd + ")");

  layoutMsg = msg: mkLuaInline ("hl.dsp.layout(" + toLua' msg + ")");

  focusWs = ws: mkLuaInline "hl.dsp.focus({ workspace = ${toLua' ws} })";

  moveWs = ws: mkLuaInline "hl.dsp.window.move({ workspace = ${toLua' ws} })";

  focusDir = direction: mkLuaInline "hl.dsp.focus({ direction = ${toLua' direction} })";

  moveDir = direction: mkLuaInline "hl.dsp.window.move({ direction = ${toLua' direction} })";

  # One ghostty window parked on a named workspace: focus it, or launch it there.
  parkedTerminal = {
    class,
    workspace,
    args,
  }: let
    selector = "class:^${lib.escapeRegex class}$";
    command = "[workspace name:${workspace}] ${ghostty} --class=${class} ${args}";
  in
    mkLuaInline ''
      function()
        if hl.get_window(${toLua' selector}) ~= nil then
          hl.dispatch(hl.dsp.focus({ window = ${toLua' selector} }))
        else
          hl.dispatch(hl.dsp.focus({ workspace = ${toLua' "name:${workspace}"} }))
          hl.exec_cmd(${toLua' command})
        end
      end
    '';

  devTerminal = parkedTerminal {
    class = "dev.terminal";
    workspace = "dev";
    args = "--working-directory=${config.home.homeDirectory}/nixos-dotfiles";
  };

  driftPlayer = parkedTerminal {
    class = "ghostty.drift";
    workspace = "music";
    args = "-e ${lib.getExe pkgs.drift}";
  };

  b = keys: dsp: {
    _args = [keys dsp];
  };

  bl = keys: dsp: {
    _args = [keys dsp {locked = true;}];
  };

  blr = keys: dsp: {
    _args = [
      keys
      dsp
      {
        locked = true;
        repeating = true;
      }
    ];
  };

  bm = keys: dsp: {
    _args = [keys dsp {mouse = true;}];
  };

  wsKeys = ["1" "2" "3" "4" "5" "6" "7" "8" "9"];
in
  [
    (b "${mainMod} + RETURN" (dspExec ghostty))
    (b "${mainMod} + ALT + RETURN" devTerminal)
    (b "${mainMod} + SHIFT + M" driftPlayer)
    (b "${mainMod} + A" herdrDrop.toggle)
    (b "${mainMod} + SHIFT + B" (dspExec "systemctl --user restart quickshell.service"))
    (b "${mainMod} + N" (dspExec "${lib.getExe config.programs.quickshell.package} ipc -c ${config.programs.quickshell.activeConfig} call notifications toggle"))
    (b "CTRL + SHIFT + Escape" (dspExec "${ghostty} --class=ghostty.btop -e btop"))

    (b "${mainMod} + SPACE" (dspExec (toString vicinaeApps)))
    (b "${mainMod} + Escape" (dspExec (toString powerMenu)))
    (b "${mainMod} + ALT + V" (dspExec "${vicinaeCmd} deeplink vicinae://launch/clipboard/history"))
    (b "ALT + SPACE" (dspExec "${hex} dictation toggle"))
    (b "${mainMod} + SHIFT + SPACE" (dspExec "fcitx5-remote -t"))

    (b "${mainMod} + SHIFT + S" (dspExec "${grimblastCmd} --freeze --notify copy area"))
    (b "${mainMod} + Print" (dspExec "${grimblastCmd} --notify copy active"))
    (b "Print" (dspExec (toString hyprPrintScreen)))

    (b "${mainMod} + E" (dspExec "${lib.getExe pkgs.nautilus} --new-window"))
    (b "${mainMod} + Z" (dspExec "zen-beta"))

    (b "XF86Launch3" (dspExec "${playerctl} play-pause"))
    (blr "XF86AudioLowerVolume" (dspExec "${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 3%-"))
    (blr "XF86AudioRaiseVolume" (dspExec "${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 3%+"))
    (bl "XF86AudioMute" (dspExec "${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle"))
    (b "${mainMod} + F10" (dspExec hyprstfu))
    (b "${mainMod} + SHIFT + F10" (dspExec "${hyprstfu} -unmute-all"))
    (b "${mainMod} + F11" (dspExec "${hyprstfu} -volume 5-"))
    (b "${mainMod} + F12" (dspExec "${hyprstfu} -volume 5+"))
    (bl "XF86AudioMicMute" (dspExec "${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))

    (b "${mainMod} + Q" (mkLuaInline "hl.dsp.window.close()"))

    (b "${mainMod} + H" (focusDir "left"))
    (b "${mainMod} + J" (focusWs "r+1"))
    (b "${mainMod} + K" (focusWs "r-1"))
    (b "${mainMod} + L" (focusDir "right"))

    (b "${mainMod} + ALT + H" (layoutMsg "swapcol l"))
    (b "${mainMod} + ALT + J" (moveDir "down"))
    (b "${mainMod} + ALT + K" (moveDir "up"))
    (b "${mainMod} + ALT + L" (layoutMsg "swapcol r"))

    (b "${mainMod} + Left" (focusDir "left"))
    (b "${mainMod} + Right" (focusDir "right"))
    (b "${mainMod} + Up" (focusDir "up"))
    (b "${mainMod} + Down" (focusDir "down"))
  ]
  ++ lib.imap1 (ws: key: b "${mainMod} + ${key}" (focusWs ws)) wsKeys
  ++ lib.imap1 (ws: key: b "${mainMod} + ALT + ${key}" (moveWs ws)) wsKeys
  ++ [
    (b "${mainMod} + SHIFT + H" (mkLuaInline ''hl.dsp.focus({ monitor = "l" })''))
    (b "${mainMod} + SHIFT + L" (mkLuaInline ''hl.dsp.focus({ monitor = "r" })''))
    (b "${mainMod} + CTRL + H" (mkLuaInline ''hl.dsp.window.move({ monitor = "l" })''))
    (b "${mainMod} + CTRL + L" (mkLuaInline ''hl.dsp.window.move({ monitor = "r" })''))

    (b "${mainMod} + comma" (layoutMsg "consume_or_expel prev"))
    (b "${mainMod} + period" (layoutMsg "consume_or_expel next"))

    (b "${mainMod} + R" (layoutMsg "colresize +conf"))
    (b "${mainMod} + M" (layoutMsg "fit active"))
    (b "${mainMod} + ALT + M" (layoutMsg "fit expand"))
    (b "${mainMod} + F" (mkLuaInline ''hl.dsp.window.fullscreen({ action = "toggle" })''))
    (b "${mainMod} + C" (layoutMsg "center"))
    (b "${mainMod} + ALT + C" (layoutMsg "fit visible"))
    (b "${mainMod} + MINUS" (layoutMsg "colresize -0.1"))
    (b "${mainMod} + EQUAL" (layoutMsg "colresize +0.1"))
    (b "${mainMod} + ALT + MINUS" (mkLuaInline "hl.dsp.window.resize({ x = 0, y = -80, relative = true })"))
    (b "${mainMod} + ALT + EQUAL" (mkLuaInline "hl.dsp.window.resize({ x = 0, y = 80, relative = true })"))
    (b "${mainMod} + T" (mkLuaInline ''hl.dsp.window.float({ action = "toggle" })''))
    (b "${mainMod} + W" (mkLuaInline "hl.dsp.group.toggle()"))
    (b "${mainMod} + TAB" (mkLuaInline "hl.dsp.group.next()"))

    (b "${mainMod} + mouse_down" (focusWs "e+1"))
    (b "${mainMod} + mouse_up" (focusWs "e-1"))
    (bm "${mainMod} + mouse:272" (mkLuaInline "hl.dsp.window.drag()"))
    (bm "${mainMod} + mouse:273" (mkLuaInline "hl.dsp.window.resize()"))

    (b "${mainMod} + SHIFT + R" (dspExec "${hyprctlCmd} reload"))
  ]
