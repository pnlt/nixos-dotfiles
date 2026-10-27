{pkgs, ...}: {
  home.packages = [
    # Claude Desktop (your xdg.nix already maps claude-desktop.desktop and the
    # claude:// scheme to it). Chromium derives the password store from the
    # desktop environment; on niri (like Hyprland) it falls through to
    # basic_text, leaving Electron's safeStorage unavailable so the app drops
    # the session right after signing in. gnome-keyring is enabled system-wide
    # in system/modules/programs/security/keyring.nix, so point it there.
    (pkgs.symlinkJoin {
      name = "claude-desktop-gnome-libsecret";
      paths = [pkgs.llm-agents.claude-desktop];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/claude-desktop --add-flags "--password-store=gnome-libsecret"
      '';
    })
  ];
}
