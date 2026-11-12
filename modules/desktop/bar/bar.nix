{...}: {
  flake.modules.homeManager.desktop = {
    config,
    pkgs,
    lib,
    ...
  }: {
    home.packages = [pkgs.libnotify];

    wayland.windowManager.hyprland.settings = {
      permission = [
        {_args = [(lib.escapeRegex "${config.programs.quickshell.package}/bin/.quickshell-wrapped") "screencopy" "allow"];}
      ];
      layer_rule = [
        {
          name = "overview";
          match.namespace = "^quickshell:overview$";
          no_anim = true;
        }
      ];
      bind = [
        {_args = ["SUPER + O" (lib.generators.mkLuaInline ''hl.dsp.global("quickshell:overview")'') {submap_universal = true;}];}
      ];
    };

    # Leaving keys reset the submap in Hyprland, so they work even if quickshell is gone.
    wayland.windowManager.hyprland.extraConfig = ''
      local function leave()
        hl.dispatch(hl.dsp.submap("reset"))
        hl.dispatch(hl.dsp.global("quickshell:overview-close"))
      end
      hl.define_submap("overview", function()
        for key, dir in pairs({ h = "left", l = "right", Left = "left", Right = "right" }) do
          hl.bind(key, function() focus_dir(dir) end)
        end
        for key, ws in pairs({ j = "r+1", k = "r-1", Down = "r+1", Up = "r-1" }) do
          hl.bind(key, hl.dsp.focus({ workspace = ws }))
        end
        for n = 1, 9 do
          hl.bind(tostring(n), hl.dsp.focus({ workspace = n }))
        end
        hl.bind("x", hl.dsp.window.close())
        for _, key in ipairs({ "Return", "Escape", "o", "space" }) do
          hl.bind(key, leave)
        end
        hl.bind("catchall", function() end)
      end)
    '';

    programs.quickshell = {
      enable = true;
      configs.bar = ./qml;
      activeConfig = "bar";
      systemd = {
        enable = true;
        target = "hyprland-session.target";
      };
    };

    # Stop with the session; otherwise it crash-loops on logout and hits the start limit.
    systemd.user.services.quickshell.Unit.PartOf = ["hyprland-session.target"];
    systemd.user.services.quickshell.Service.Environment = [
      # Tray icons fail to resolve without an explicit theme
      "QS_ICON_THEME=Adwaita"
      # tailscaled closes the LocalAPI socket after every status poll
      "QT_LOGGING_RULES=quickshell.io.socket.warning=false"
    ];
  };
}
