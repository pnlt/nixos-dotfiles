{...}: {
  flake.modules.homeManager.social = {pkgs, ...}: {
    home.packages = [pkgs.discord];
  };
}
