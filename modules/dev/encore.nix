{...}: {
  flake.modules.homeManager.dev = {
    programs.encore = {
      enable = true;
      settings = {
        browser = "never";
      };
    };
  };
}
