{
  config,
  pkgs,
  lib,
  ...
}: let
  kdl = lib.concatStringsSep "\n\n" [
    (import ./input.nix {})
    (import ./environment.nix {})
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

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };
}
