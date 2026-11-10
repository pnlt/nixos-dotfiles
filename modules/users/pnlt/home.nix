{config, ...}: let
  inherit (config.meta) user nix;
in {
  flake.modules.homeManager.pnlt = {
    config,
    pkgs,
    ...
  }: let
    dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
    create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
    configs = {
      nvim = "nvim";
    };
  in {
    xdg.configFile =
      builtins.mapAttrs (_name: subpath: {
        source = create_symlink "${dotfiles}/${subpath}";
        recursive = true;
      })
      configs;

    home = {
      inherit (nix) stateVersion;

      enableNixpkgsReleaseCheck = true;
      homeDirectory = "/home/${user.alias}";
      username = "${user.alias}";

      packages = with pkgs; [
        home-manager
        neovim
      ];
    };

    news.display = "silent";

    # Faster home-manager eval
    manual = {
      html.enable = false;
      manpages.enable = false;
      json.enable = false;
    };
    programs.home-manager.enable = false;
  };
}
