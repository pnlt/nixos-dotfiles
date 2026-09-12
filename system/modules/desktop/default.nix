{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./clipboard.nix
    ./niri.nix
    ./fonts
  ];

  programs.dconf.enable = true;

  programs.ttygate = {
    enable = true;
    sessionCmd = ["${pkgs.niri}/bin/niri-session"];
    # or: [ "${config.programs.niri.package}/bin/niri-session" ]
    accent = "amber";
    idleStatus = "AWAITING IDENTIFICATION";
    defaultUser = "pnlt";
    journalUser = "greeter";
  };

  services = {
    # graphical-desktop.nix turns speechd on by mkDefault for any desktop. no
    # screen reader here, and its module probes leave unreaped children behind.
    speechd.enable = false;

    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = lib.getExe config.programs.ttygate.package;
        };
      };
    };
  };
}
