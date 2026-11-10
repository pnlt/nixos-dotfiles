{...}: {
  flake.modules.homeManager.media = {pkgs, ...}: let
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
      exec = "feh --fullscreen %f";
      genericName = "Image Viewer";
    };

    sxiv = mkWithDesktopItemWrapper {
      package = pkgs.sxiv;
      desktopName = "svix";
      name = "sxiv (gif)";
      exec = "sxiv -a %f";
      genericName = "Gif Viewer";
    };
  in {
    home.packages = [
      pkgs.imagemagick
      sxiv.new
      feh.new
    ];

    xdg.mimeApps = let
      heliumDesktop = "helium.desktop";

      defaultApps = {
        "image/*" = [feh.desktopFile];
        "image/gif" = [sxiv.desktopFile];
      };

      unsetHelium = builtins.mapAttrs (_: _: [heliumDesktop]) defaultApps;
    in {
      defaultApplications = defaultApps;

      associations = {
        added = defaultApps;
        removed = unsetHelium;
      };
    };
  };
}
