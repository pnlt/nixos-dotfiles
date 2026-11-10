{...}: {
  flake.modules.homeManager.desktop = {
    programs.hex = {
      enable = true;
      autostart = true;
      installModel = true;
      settings = {
        paste_with_shift = true;
        "labs.live_text" = true;
      };
    };
  };
}
