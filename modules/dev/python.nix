{...}: {
  flake.modules.homeManager.dev = {pkgs, ...}: {
    home.packages = with pkgs; [
      (python313.withPackages
        (p:
          with p; [
            pyserial # required by arduino ide
            pip
          ]))
      virtualenv # to create raw environments
      poetry # package manager
      pyright # linter
    ];
  };
}
