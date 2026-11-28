{...}: {
  flake.modules.nixos.desktop = {
    config,
    pkgs,
    ...
  }: let
    hyprctl = "${config.programs.hyprland.package}/bin/hyprctl";

    headlessUp = pkgs.writeShellScript "sunshine-headless-up" ''
      set -eu
      ${hyprctl} output remove SUNSHINE >/dev/null 2>&1 || true
      ${hyprctl} output create headless SUNSHINE
      # Physical outputs go off only after SUNSHINE exists, so workspaces migrate instead of orphaning
      ${hyprctl} eval 'hl.monitor({ output = "HDMI-A-1", disabled = true })'
      ${hyprctl} eval 'hl.monitor({ output = "DP-2", disabled = true })'
      # Sunshine maps absolute mouse input using the offset it reads once at stream start
      ${hyprctl} eval "hl.monitor({ output = \"SUNSHINE\", mode = \"''${SUNSHINE_CLIENT_WIDTH}x''${SUNSHINE_CLIENT_HEIGHT}@''${SUNSHINE_CLIENT_FPS}\", position = \"0x0\", scale = 1 })"
      ${hyprctl} dispatch 'hl.dsp.focus({ monitor = "SUNSHINE" })'
      # awww runs with --no-cache, so a new output starts without a wallpaper
      ${pkgs.awww}/bin/awww img -o SUNSHINE "$HOME/Pictures/wallpapers/do-ye-eun-original-panel-2560x1440.jpg" || true
    '';

    headlessDown = pkgs.writeShellScript "sunshine-headless-down" ''
      ${hyprctl} output remove SUNSHINE
      ${hyprctl} reload
      ${pkgs.awww}/bin/awww img "$HOME/Pictures/wallpapers/do-ye-eun-original-panel-2560x1440.jpg" || true
    '';

    inherit (config.services.sunshine.settings) port;
  in {
    services.sunshine = {
      enable = true;
      autoStart = true;
      settings = {
        sunshine_name = config.networking.hostName;
        # KMS cannot see headless outputs; wlr-screencopy can
        capture = "wlr";
        encoder = "vaapi";
        adapter_name = "/dev/dri/renderD128";
        output_name = "SUNSHINE";
        vaapi_strict_rc_buffer = "enabled";
        csrf_allowed_origins = "https://${config.networking.hostName}:47990";
      };
      applications.apps = [
        {
          name = "Desktop";
          prep-cmd = [
            {
              do = toString headlessUp;
              undo = toString headlessDown;
            }
          ];
          auto-detach = "true";
        }
      ];
    };

    # A dropped or killed client leaves the app running, so the undo never fires and the
    # physical monitors stay off. Restarting Sunshine terminates the app, which runs the undo.
    systemd.user.services.sunshine-reset = {
      description = "Restart Sunshine when a client disconnects";
      after = ["sunshine.service"];
      partOf = ["graphical-session.target"];
      # Not graphical-session.target: the target orders after what it wants, and sunshine
      # orders after the target, which forms a cycle that systemd breaks by dropping this unit
      wantedBy = ["sunshine.service"];
      path = [pkgs.systemd pkgs.gnugrep];
      script = ''
        journalctl --user -u sunshine -f -n 0 -o cat \
          | grep --line-buffered 'CLIENT DISCONNECTED' \
          | while read -r _; do systemctl --user restart sunshine; done
      '';
    };

    # Reached over the tailnet only; Sunshine treats 100.64.0.0/10 as LAN for the web UI
    services.avahi.enable = false;
    networking.firewall.interfaces.tailscale0 = {
      allowedTCPPorts = map (o: port + o) [(-5) 0 1 21];
      allowedUDPPorts = map (o: port + o) [9 10 11 13 21];
    };
  };

  # A config reload mid-stream (home-manager switch) re-applies the monitor rules, waking the
  # physical outputs and pushing SUNSHINE off 0x0, where Sunshine's mouse mapping expects it.
  flake.modules.homeManager.desktop.wayland.windowManager.hyprland.extraConfig = ''
    local sunshine = hl.get_monitor("SUNSHINE")
    if sunshine then
      hl.monitor({ output = "HDMI-A-1", disabled = true })
      hl.monitor({ output = "DP-2", disabled = true })
      hl.monitor({
        output = "SUNSHINE",
        mode = string.format("%dx%d@%g", sunshine.width, sunshine.height, sunshine.refresh_rate),
        position = "0x0",
        scale = 1,
      })
    end
  '';
}
