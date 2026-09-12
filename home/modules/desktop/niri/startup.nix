{
  config,
  pkgs,
  lib,
  ...
}: let
  home = config.home.homeDirectory;
  # optional scripts — only spawn if you still keep them
  xclipScript = "${home}/.config/niri/scripts/xclip";
  dynamicRules = "${home}/.config/niri/scripts/dynamic-rules";
in ''
  // --- startup (dms removed) ---
  spawn-at-startup "awww-daemon"
  spawn-at-startup "awww" "img" "${config.home.homeDirectory}/nixos-dotfiles/home/modules/desktop/awww/wallpapers/cba.png"
  spawn-at-startup "${pkgs.wl-clipboard}/bin/wl-paste" "--watch" "${pkgs.cliphist}/bin/cliphist" "store"
  spawn-at-startup "${xclipScript}"
  spawn-at-startup "${pkgs.udiskie}/bin/udiskie"
  spawn-at-startup "${pkgs.easyeffects}/bin/easyeffects" "--gapplication-service"
  spawn-at-startup "zen-beta"
  spawn-at-startup "${dynamicRules}"

''
