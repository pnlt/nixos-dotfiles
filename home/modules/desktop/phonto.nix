{
  config,
  lib,
  pkgs,
  ...
}: let
  walls = "${config.home.homeDirectory}/Videos/wallpapers";
in {
  systemd.user.services.phonto = {
    Unit = {
      Description = "phonto video wallpaper";
      PartOf = ["graphical-session.target"];
      After = ["graphical-session.target"];
    };
    Service = {
      ExecStart = lib.concatStringsSep " " [
        (lib.getExe pkgs.phonto)
        "--display DP-2 ${walls}/oneway-smoke.mp4"
        "--display HDMI-A-1 ${walls}/samurai-white-lily-portrait.mp4"
      ];
      Restart = "on-failure";
    };
    Install.WantedBy = ["graphical-session.target"];
  };
}
