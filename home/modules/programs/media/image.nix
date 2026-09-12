{pkgs, ...}: let
  mkWithDesktopItemWrapper = {
    package,
    desktopName,
    exec,
    genericName,
    name ? desktopName,
  }: {
    new = package.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [pkgs.copyDesktopItems];
      desktopItems = [
        (pkgs.makeDesktopItem {
          inherit name desktopName exec genericName;
        })
      ];
    });
    desktopFile = "${desktopName}.desktop";
  };

  feh = mkWithDesktopItemWrapper {
    package = pkgs.feh;
    desktopName = "feh";
    exec = "feh %f";
    genericName = "Image Viewer";
  };

  sxiv = mkWithDesktopItemWrapper {
    package = pkgs.sxiv;
    desktopName = "sxiv";
    name = "sxiv";
    exec = "sxiv -a %f";
    genericName = "Gif Viewer";
  };
in {
  home.packages = [
    pkgs.imagemagick
    feh.new
    sxiv.new
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "image/svg+xml" = ["feh.desktop"];
      "image/png" = ["feh.desktop"];
      "image/jpeg" = ["feh.desktop"];
      "image/jpg" = ["feh.desktop"];
      "image/gif" = ["sxiv.desktop"];
      "image/webp" = ["feh.desktop"];
    };
  };
}
