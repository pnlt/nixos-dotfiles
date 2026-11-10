{...}: {
  flake.modules.homeManager.office = {pkgs, ...}: {
    home.packages = with pkgs; [
      onlyoffice-desktopeditors
    ];
  };
}
