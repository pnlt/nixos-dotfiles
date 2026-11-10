{...}: {
  flake.modules.homeManager.media = {pkgs, ...}: {
    home.packages = [pkgs.drift];

    # YouTube answers 403 on a fresh stream URL for a few seconds; yt-dlp's
    # downloader waits it out, mpv streaming the URL directly does not.
    xdg.configFile."drift/config.toml" = {
      source = (pkgs.formats.toml {}).generate "drift-config.toml" {
        audio = {
          download = true;
          download_max_minutes = 0;
        };
      };
      force = true;
    };
  };
}
