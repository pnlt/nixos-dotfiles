{...}: {
  flake.modules.homeManager.desktop = {
    services.heft = {
      enable = true;
      warnFreeGiB = 100;
      criticalFreeGiB = 50;
    };
  };
}
