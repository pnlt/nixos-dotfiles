{
  config,
  pkgs,
  lib,
  ...
}: let
  kdl = lib.concatStringsSep "\n\n" [
    (import ./input.nix {})
    (import ./cursor.nix {})
    (import ./output.nix {})
    (import ./layout.nix {})
    (import ./misc.nix {inherit pkgs;})
    (import ./startup.nix {inherit config pkgs lib;})
    (import ./window-rules.nix {})
    (import ./binds.nix {inherit config pkgs lib;})
  ];
in {
  xdg.configFile."niri/config.kdl" = {
    text = kdl;
    force = true;
  };

  # Shadows the packaged Terminal=true entry so launchers get the ghostty.btop app-id
  # that the floating window rule matches.
  xdg.desktopEntries.btop = {
    name = "btop++";
    comment = "Resource monitor";
    icon = "btop";
    exec = "${lib.getExe config.programs.ghostty.package} --class=ghostty.btop -e btop";
    terminal = false;
    categories = ["System" "Monitor"];
  };

  home.sessionVariables = {
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_QPA_PLATFORMTHEME = "gtk3";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
  };
}
