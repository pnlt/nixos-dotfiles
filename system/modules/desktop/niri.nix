{pkgs, ...}: {
  programs = {
    niri = {
      enable = true;
      package = pkgs.niri;
    };
  };
  environment.systemPackages = with pkgs; [
    xwayland-satellite
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    # ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  };
}
