{
  config,
  lib,
  pkgs,
  ...
}: let
  seedConfig = pkgs.writeText "tide-island-userconfig.json" (builtins.toJSON {
    wallpaperLibraryPath = "${config.home.homeDirectory}/Pictures/wallpapers";
  });
in {
  # Settings app and desktop entries; ~/.config/tide-island stays app-managed
  home.packages = [pkgs.tide-island];

  # Tide opens its settings app on every start while userconfig.json is missing.
  # Seeded once so the settings app can keep writing to it.
  home.activation.tideIslandUserConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    f=${config.xdg.configHome}/tide-island/userconfig.json
    [ -e "$f" ] || run install -Dm644 ${seedConfig} "$f"
  '';

  # Tide's wallpaper picker drives awww; the daemon restores the last image
  services.awww.enable = true;

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
