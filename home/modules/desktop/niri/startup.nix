{
  config,
  pkgs,
  lib,
  ...
}: ''
  // --- startup ---
  spawn-at-startup "${lib.getExe config.programs.waybar.package}"

  spawn-at-startup "${pkgs.easyeffects}/bin/easyeffects" "--gapplication-service"
''
