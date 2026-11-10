{...}: {
  flake.modules.homeManager.shell = {pkgs, ...}: {
    home.packages = with pkgs; [
      translate-shell
    ];
  };
}
