{
  config,
  pkgs,
  inputs,
  user,
  nix,
  ...
}: let
  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  configs = {
    nvim = "nvim";
  };
in {
  imports = [
    ../../modules
  ];

  xdg.configFile =
    (builtins.mapAttrs
      (name: subpath: {
        source = create_symlink "${dotfiles}/${subpath}";
        recursive = true;
      })
      configs)
    // {
    };

  home = {
    inherit (nix) stateVersion;

    enableNixpkgsReleaseCheck = true;
    homeDirectory = "/home/${user.alias}";
    username = "${user.alias}";

    packages = with pkgs; [
      neovim
      ripgrep
      gcc
    ];

    sessionVariables = {
      DO_NOT_TRACK = 1;
      ENABLE_TELEMETRY = 0;
      TELEMETRY_ENABLED = 0;
    };
  };

  news.display = "silent";
}
