{}: ''
    // default chrome
    window-rule {
        geometry-corner-radius 8
        clip-to-geometry true
        draw-border-with-background false
    }

    // Maximized
    window-rule {
        match app-id="zen-beta"
        match app-id="calibre-gui"
        open-maximized true
    }

    // PiP floating
    window-rule {
        match app-id=r#"firefox$"# title="^Picture-in-Picture$"
        match app-id="zen-beta" title="^Picture-in-Picture$"
        open-floating true
        open-focused false
        default-floating-position x=32 y=32 relative-to="bottom-right"
        default-column-width { proportion 0.3; }
        default-window-height { proportion 0.3; }
    }

    // Dialogs
    window-rule {
        match app-id="confirm"
        match app-id="pavucontrol"
        match app-id="nm-connection-editor"
        match app-id="org.gnome.PowerStats"
        match app-id="cpupower"
        match app-id="easyeffects"
        match app-id="Hello"
        match app-id="xdg-desktop-portal-gtk"
        match app-id="ghostty_journalctl"
        match title=r#".*Extension.*Bitwarden.*"#
        match app-id="brave-keep"
        open-floating true
        default-column-width { proportion 0.45; }
        default-window-height { proportion 0.45; }
    }
   window-rule {
      match app-id="waybar.nmtui"
      open-floating true
      // optional size — niri uses different sizing APIs than hypr
  }

    // btop via keybind or vicinae (btop.desktop override in default.nix)
    window-rule {
        match app-id="ghostty.btop"
        open-floating true
        default-column-width { proportion 0.95; }
        default-window-height { proportion 0.8; }
    }

    // Floating Terminal / dev workspace
    window-rule {
        match app-id="dev.terminal"
        open-maximized true
        open-on-workspace "dev"
    }

    // herdr hub (agents) — toggled with Mod+A, see binds.nix
    window-rule {
        match app-id="ghostty.herdr"
        open-maximized true
        open-on-workspace "hub"
    }
''
