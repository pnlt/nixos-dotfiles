{config, ...}: let
  inherit (config.meta) host nix;
in {
  flake.modules.nixos.HOST = {
    networking.hostName = host.name;

    time.timeZone = host.timeZone;
    i18n.defaultLocale = host.i18nLocale;
    documentation.enable = false;

    system.stateVersion = nix.stateVersion;
  };
}
