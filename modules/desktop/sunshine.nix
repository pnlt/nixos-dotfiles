{...}: {
  flake.modules.nixos.desktop = {
    config,
    pkgs,
    ...
  }: let
    hyprctl = "${config.programs.hyprland.package}/bin/hyprctl";

    headlessUp = pkgs.writeShellScript "sunshine-headless-up" ''
      set -eu
      ${hyprctl} eval 'hl.monitor({ output = "HDMI-A-1", disabled = true })'
      ${hyprctl} output remove SUNSHINE >/dev/null 2>&1 || true
      ${hyprctl} output create headless SUNSHINE
      ${hyprctl} eval "hl.monitor({ output = \"SUNSHINE\", mode = \"''${SUNSHINE_CLIENT_WIDTH}x''${SUNSHINE_CLIENT_HEIGHT}@''${SUNSHINE_CLIENT_FPS}\", position = \"auto-right\", scale = 1 })"
      ${hyprctl} dispatch 'hl.dsp.focus({ monitor = "SUNSHINE" })'
    '';

    headlessDown = pkgs.writeShellScript "sunshine-headless-down" ''
      ${hyprctl} output remove SUNSHINE
      ${hyprctl} reload
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

    # Reached over the tailnet only; Sunshine treats 100.64.0.0/10 as LAN for the web UI
    services.avahi.enable = false;
    networking.firewall.interfaces.tailscale0 = {
      allowedTCPPorts = map (o: port + o) [(-5) 0 1 21];
      allowedUDPPorts = map (o: port + o) [9 10 11 13 21];
    };
  };
}
