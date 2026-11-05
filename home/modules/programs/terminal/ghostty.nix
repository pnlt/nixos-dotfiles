{
  inputs,
  system,
  ...
}: {
  shared.ghostty = {
    enable = true;
    package = inputs.ghostty.packages.${system}.default.overrideAttrs (old: {
      patches =
        (old.patches or [])
        ++ [
          ./patches/tmux-osc7-passthrough.patch
        ];
    });
    settings = {
      # font-family = "FantasqueSansM Nerd Font Mono";
      font-family = "PlemolJP Console NF";
      font-size = "18";
      gtk-titlebar = "false";
      window-show-tab-bar = "never";
      custom-shader = "/home/pnlt/nixos-dotfiles/config/ghostty/shaders/cursor.glsl";
    };
  };
}
