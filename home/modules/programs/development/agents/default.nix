{
  nixosConfig,
  config,
  pkgs,
  libx,
  lib,
  ...
}: {
  _module.args = import ./lib.nix {inherit nixosConfig pkgs lib libx config;};

  imports = [
    ./apps
    ./cli
    ./hooks
    ./mcp.nix
    ./options
    ./shell.nix
    ./skills.nix
  ];

  # luisquin also enables `services.strikedddd` here. It comes from his private
  # flake input (git+ssh://github.com/0xc000022070/striked) and cannot be
  # fetched from this repo, so the statusline and engine hooks that used it are
  # wired straight to ccstatusline / dropped in ./cli/claude.
}
