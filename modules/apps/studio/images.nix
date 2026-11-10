{...}: {
  flake.modules.homeManager.studio = {pkgs, ...}: {
    home.packages = [
      pkgs.gimp
    ];
  };
}
