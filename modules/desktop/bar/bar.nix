{...}: {
  flake.modules.homeManager.desktop = {pkgs, ...}: {
    home.packages = [pkgs.libnotify];

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
