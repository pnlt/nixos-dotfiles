{
  lib,
  pkgs,
  ...
}: {
  # Settings app and desktop entries; ~/.config/tide-island stays app-managed
  home.packages = [pkgs.tide-island];

  # Shadows the packaged unit, which points at /usr/bin and would start under niri too
  systemd.user.services.tide-island = {
    Unit = {
      Description = "Tide Island dynamic island shell";
      PartOf = ["hyprland-session.target"];
      After = ["hyprland-session.target"];
    };
    Service = {
      ExecStart = lib.getExe pkgs.tide-island;
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install.WantedBy = ["hyprland-session.target"];
  };
}
