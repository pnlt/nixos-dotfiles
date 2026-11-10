{...}: {
  flake.modules.homeManager.hardware = {
    services.udiskie = {
      enable = true;
      notify = true;
      tray = "auto";
    };
  };
}
