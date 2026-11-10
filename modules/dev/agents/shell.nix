{...}: {
  flake.modules.homeManager.agents = {
    programs.zsh.initContent = builtins.readFile (builtins.path {
      name = "agents-shrc";
      path = ./shell.zsh;
    });
  };
}
