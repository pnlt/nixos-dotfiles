{
  pkgs,
  host,
  ...
}: {
  shared = {
    aliases.enable = true;
    zsh.enable = true;
  };

  environment = {
    interactiveShellInit = builtins.readFile (builtins.path {
      name = "${host.name}-system-shrc-script";
      path = ./.shrc;
    });

    variables.EDITOR = "nvim";

    shells = [pkgs.zsh];
  };
}
