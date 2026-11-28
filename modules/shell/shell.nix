{
  flake.modules.homeManager.shell = {lib, ...}: {
    programs.zsh.initContent = builtins.readFile ./.zshrc;

    programs.direnv-instant.enable = true;

    programs.atuin = {
      enable = true;
      flags = ["--disable-up-arrow"];
      settings.update_check = false;
    };
    programs.fzf.historyWidget.command = "";

    programs.fastfetch.settings.logo = lib.mkForce {
      type = "kitty-direct";
      source = "${./ye-eun-fastfetch.png}";
      width = 19;
      height = 14;
      padding = {
        left = 2;
        right = 4;
      };
    };

    shared = {
      bat.enable = true;
      btop.enable = true;
      direnv.enable = true;
      eza.enable = true;
      fzf.enable = true;
      less.enable = true;
      fastfetch.enable = true;
      magic-wormhole.enable = true;
      starship.enable = true;
      tmux = {
        enable = true;
        # Replaced by the attach-or-create launcher in programs/terminal.
        autoStart = false;
        status = {
          ssh.enable = true;
          gpg.enable = true;
          lsyncd = {
            enable = true;
            hideOnRemoteSsh = true;
          };
          git.enable = true;
        };
      };
      zoxide.enable = true;
      zsh.enable = true;
    };
  };
}
