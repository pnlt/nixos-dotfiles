{
  config,
  pkgs,
  lib,
  ...
}: let
  hasEww = config.programs.eww.enable or false;
  hasHark = config.services.hark.enable or false;
  hasHeft = config.services.heft.enable or false;

  ewwToggle = name:
    if hasEww
    then
      lib.getExe (pkgs.writeShellApplication {
        name = "eww-toggle-${name}";
        runtimeInputs = [config.programs.eww.package];
        text = ''
          target="$1"
          open=$(eww active-windows 2>/dev/null || true)
          eww close-all 2>/dev/null || true
          if ! grep -q "^$target" <<<"$open"; then
            eww open "$target"
          fi
        '';
      })
      + " ${name}"
    else "";

  notificationsClick =
    if hasEww && hasHark
    then
      lib.getExe (pkgs.writeShellApplication {
        name = "waybar-notifications";
        runtimeInputs = [config.programs.eww.package pkgs.hark];
        text = ''
          if eww active-windows 2>/dev/null | grep -q "^notifications"; then
            eww close notifications
            hark seen
            exit 0
          fi
          eww close-all 2>/dev/null || true
          eww open notifications
        '';
      })
    else if hasHark
    then "${pkgs.mako}/bin/makoctl history"
    else "${pkgs.mako}/bin/makoctl history";
in {
  programs.waybar = {
    enable = true;
    systemd.enable = true; # starts with session

    style = builtins.readFile ./foe.css;

    settings = [
      {
        position = "top";
        layer = "top";
        # omit "output" to show on all monitors (desktop / multi-head)
        # output = [ "HDMI-A-1" ];

        modules-left = [
          "custom/launcher"
          "niri/workspaces"
          "niri/window"
          "tray"
        ];

        modules-center = [
          "clock"
        ];

        modules-right =
          [
            "custom/notifications"
          ]
          ++ lib.optionals hasHeft ["custom/heft"]
          ++ [
            "group/sysmon"
            "network" # ethernet: format-ethernet icon
            "pulseaudio"
          ];

        "group/sysmon" = {
          orientation = "vertical";
          modules = ["cpu" "memory"];
        };

        # --- Niri (was hyprland/workspaces) ---
        "niri/workspaces" = {
          format = "{icon}";
          format-icons = {
            "1" = "一";
            "2" = "二";
            "3" = "三";
            "4" = "四";
            "5" = "五";
            "6" = "六";
            "7" = "七";
            "8" = "八";
            "9" = "九";
            "10" = "十";
            default = "·";
          };
        };

        "niri/window" = {
          max-length = 48;
          separate-outputs = true;
        };

        "custom/launcher" = {
          format = " ";
          tooltip = false;
          on-click = "${lib.getExe pkgs.fuzzel}";
        };

        "custom/notifications" =
          if hasHark
          then {
            exec = "${lib.getExe pkgs.hark} waybar --watch";
            return-type = "json";
            escape = false;
            restart-interval = 5;
            tooltip = true;
            on-click = notificationsClick;
            on-click-right = "${lib.getExe pkgs.hark} dnd toggle";
            on-click-middle = "${lib.getExe pkgs.hark} clear";
          }
          else {
            format = "󰂚";
            tooltip = false;
            on-click = "${pkgs.mako}/bin/makoctl history";
          };

        "custom/heft" = lib.mkIf hasHeft {
          exec =
            "${lib.getExe pkgs.heft} waybar"
            + " --warn-free ${toString (config.services.heft.warnFreeGiB or 20)}"
            + " --critical-free ${toString (config.services.heft.criticalFreeGiB or 10)}";
          return-type = "json";
          interval = 300;
          tooltip = true;
          on-click = ewwToggle "heft";
        };

        clock = {
          interval = 60;
          format = " {:%H:%M}";
          tooltip = true;
          tooltip-format = "{:%A, %B %d %Y}";
          on-click = ewwToggle "calendar";
        };

        cpu = {
          interval = 2;
          format = "󰍛 {usage}%";
          on-click = ewwToggle "sysmon";
        };

        memory = {
          interval = 2;
          format = " {percentage}%";
          states = {
            warning = 80;
            critical = 95;
          };
          on-click = ewwToggle "sysmon";
        };

        # Ethernet desktop — no battery, wifi secondary
        network = {
          format-ethernet = "󰈀";
          format-wifi = "{icon}";
          format-linked = "󰤫";
          format-disconnected = "󰤮";
          format-icons = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
          tooltip = true;
          tooltip-format-ethernet = "{ifname} {ipaddr}";
          interval = 5;
          on-click = ewwToggle "network";
        };

        pulseaudio = {
          format = "{volume}% {icon}";
          format-muted = "󰝟";
          format-icons.default = ["󰕿" "󰖀" "󰕾"];
          on-click = "${lib.getExe pkgs.pavucontrol}";
        };

        tray = {
          icon-size = 15;
          spacing = 10;
        };
      }
    ];
  };
}
