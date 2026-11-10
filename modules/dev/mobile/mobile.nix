{...}: {
  flake.modules.homeManager.mobile = {
    programs.phone = {
      enable = true;
      pools.android = ["galaxy-s26-plus"];
    };
  };
}
