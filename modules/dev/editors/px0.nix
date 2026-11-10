{...}: {
  flake.modules.homeManager.editors = {pkgs, ...}: {
    home.packages = [pkgs.px0];
  };
}
