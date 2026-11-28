{...}: {
  flake.modules.homeManager.desktop = {config, ...}: {
    xdg.configFile."mimeapps.list".force = true;

    xdg = {
      enable = true;
      userDirs = let
        home = config.home.homeDirectory;
      in {
        enable = true;
        createDirectories = true;
        desktop = null;
        download = "${home}/Downloads";
        documents = "${home}/Documents";
        pictures = "${home}/Pictures";
        music = null;
        publicShare = null;
        templates = null;
        videos = "${home}/Videos";
      };

      mimeApps = let
        vlc = ["vlc.desktop"];
        zathura = ["zathura.desktop"];
        zed = ["dev.zed.Zed.desktop"];
        claude = ["com.anthropic.Claude.desktop"];

        associations = {
          "inode/directory" = ["dev.noctalia.luciole.desktop"];
          "application/pdf" = zathura;
          "x-scheme-handler/claude" = claude;
          "x-scheme-handler/unityhub" = ["unityhub.desktop"];

          "video/mp4" = vlc;
          "video/x-matroska" = vlc;
          "video/webm" = vlc;
          "video/x-msvideo" = vlc;

          "audio/mpeg" = vlc;
          "audio/flac" = vlc;
          "audio/ogg" = vlc;

          "text/x-python" = zed;
          "text/plain" = zed;
          "application/json" = zed;
        };
      in {
        enable = true;
        associations.added = associations;
        defaultApplications = associations;
      };
    };
  };
}
