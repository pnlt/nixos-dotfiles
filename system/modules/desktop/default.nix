{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./clipboard.nix
    # ./niri.nix
    ./hyprland.nix
    ./fonts
  ];

  programs.dconf.enable = true;

  # Session picker shown after logging out; boot autologins hyprland
  programs.ttygate = {
    enable = true;
    sessions = [
      {
        name = "hyprland";
        command = ["${pkgs.hyprland}/bin/start-hyprland"];
      }
      # {
      #   name = "niri";
      #   command = ["${pkgs.niri}/bin/niri-session"];
      # }
      {
        name = "tty";
        command = [(lib.getExe pkgs.zsh) "-l"];
      }
    ];
    defaultUser = "pnlt";
    journalUser = "greeter";
  };

  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v24n.psf.gz";
    packages = [pkgs.terminus_font];
  };

  services = {
    # graphical-desktop.nix turns speechd on by mkDefault for any desktop. no
    # screen reader here, and its module probes leave unreaped children behind.
    speechd.enable = false;
    greetd = {
      enable = true;
      settings = {
        initial_session = {
          command = "${pkgs.hyprland}/bin/start-hyprland";
          user = "pnlt";
        };
        # The bare VT is sized to the smallest monitor (HDMI 1080p), so ttygate
        # runs under cage with HDMI off to get DP-2's native 1440p.
        default_session.command = toString (pkgs.writeShellScript "ttygate-cage" ''
          exec ${lib.getExe pkgs.cage} -s -d -- ${pkgs.writeShellScript "ttygate-foot" ''
            ${lib.getExe pkgs.wlr-randr} --output HDMI-A-1 --off || true
            exec ${lib.getExe pkgs.foot} -o font="JetBrains Mono:size=16" ${lib.getExe config.programs.ttygate.package}
          ''}
        '');
      };
    };
  };
}
