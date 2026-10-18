{config, ...}: {
  services.linux-wallpaperengine = {
    enable = true;
    assetsPath = "${config.home.homeDirectory}/.local/share/Steam/steamapps/common/wallpaper_engine/assets";

    audio.silent = true;
    fps = 30;
    wallpapers = [
      {
        monitor = "DP-2";
        # wallpaper = "3450329622";
        wallpaper = "3551182863";
      }

      {
        monitor = "HDMI-A-1";
        # wallpaper = "3613238253";
        wallpaper = "3299228616";
        scaling = "fill";
      }
    ];
  };
  systemd.user.services.linux-wallpaperengine = {
    Unit.After = [
      "pipewire.service"
      "pipewire-pulse.service"
      "wireplumber.service"
    ];
    Service = {
      KillSignal = "SIGINT";
      TimeoutStopSec = "3s";
    };
  };
}
