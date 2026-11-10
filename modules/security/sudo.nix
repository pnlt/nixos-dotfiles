{...}: {
  flake.modules.nixos.security = {
    security.sudo = {
      enable = true;
      execWheelOnly = true;
      wheelNeedsPassword = true;
    };
  };
}
