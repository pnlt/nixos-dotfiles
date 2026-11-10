{...}: {
  flake.modules.homeManager.agents = {pkgs, ...}: {
    home.packages = [pkgs.rtk];
  };
}
