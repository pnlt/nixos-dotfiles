{...}: {
  flake.modules.homeManager.media = {pkgs, ...}: {
    home.packages = [
      pkgs.vlc
    ];
  };
}
