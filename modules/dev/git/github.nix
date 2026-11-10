{...}: {
  flake.modules.homeManager.git = {
    programs.github-tools = {
      enable = true;
      act = true;
      cli = true; # gh
      tui = true; # ght
    };
  };
}
