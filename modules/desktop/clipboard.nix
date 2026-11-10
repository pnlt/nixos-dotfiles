{config, ...}: let
  inherit (config.meta) host;
in {
  flake.modules.nixos.desktop = {pkgs, ...}:
    if host.wayland
    then {
      environment.systemPackages = with pkgs; [
        wl-clipboard
      ];
    }
    else {
      environment = {
        systemPackages = [pkgs.xclip];

        shellAliases = {
          xclip = "xclip -selection c";
        };
      };
    };
}
