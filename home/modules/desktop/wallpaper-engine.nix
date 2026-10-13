{config, ...}: {
  services.linux-wallpaperengine = {
    enable = true;
    assetsPath = "${config.home.homeDirectory}/.local/share/Steam/steamapps/common/wallpaper_engine/assets";

    audio.silent = true;
    fps = 30;
    wallpapers = [
      {
        monitor = "DP-2";
        wallpaper = "3450329622";
      }

      {
        monitor = "HDMI-A-1";
        wallpaper = "3613238253";
        scaling = "fill";
      }
    ];
  };
}
