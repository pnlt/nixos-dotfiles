{pkgs, ...}: {
  programs = {
    niri = {
      enable = true;
      package = pkgs.niri;
    };
  };
  # gnome portal advertises GlobalShortcuts but niri lacks the GNOME Shell
  # key-grab API, so binds fail; hiding it makes apps use compositor binds
  xdg.portal.config.niri."org.freedesktop.impl.portal.GlobalShortcuts" = "none";

  environment.systemPackages = with pkgs; [
    xwayland-satellite
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
}
