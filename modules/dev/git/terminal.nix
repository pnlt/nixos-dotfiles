{...}: {
  flake.modules.homeManager.git = {
    programs.zsh.initContent = builtins.readFile (builtins.path {
      name = "git-shrc";
      path = ./dots/shell.zsh;
    });
  };
}
