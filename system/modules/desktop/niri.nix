{pkgs, ...}: {
  programs = {
    niri = {
      enable = true;
      package = pkgs.niri;
    };
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    # ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  };
}
