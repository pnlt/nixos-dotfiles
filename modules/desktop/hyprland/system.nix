{...}: {
  flake.modules.nixos.desktop = {pkgs, ...}: {
    environment.pathsToLink = ["/libexec"];

    programs.hyprland = {
      enable = true;
      package = pkgs.hyprland;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
    };

    environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
