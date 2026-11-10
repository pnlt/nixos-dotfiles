{...}: {
  flake.modules.homeManager.git = {pkgs, ...}: {
    home.packages = [
      pkgs.git-cliff
      pkgs.git-open
    ];
  };
}
