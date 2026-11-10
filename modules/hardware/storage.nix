{...}: {
  flake.modules.homeManager.hardware = {
    services.udiskie = {
      enable = true;
      # automount = true;
      notify = true;
      tray = "auto";
    };
  };
}
