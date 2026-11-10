{...}: {
  flake.modules.homeManager.pwn = {pkgs, ...}: {
    home.packages = [
      pkgs.cmatrix
      pkgs.genact
    ];
  };
}
