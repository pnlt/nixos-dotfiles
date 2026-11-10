{config, ...}: let
  inherit (config.meta) user;
in {
  flake.modules.nixos.gaming = {pkgs, ...}: {
    environment = {
      systemPackages = [
        pkgs.protonup-ng
        pkgs.steam-run
      ];

      sessionVariables = {
        STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/${user.alias}/.steam/root/compatibilitytools.d";
      };
    };

    programs = {
      steam = {
        enable = true;
        gamescopeSession.enable = true;
      };

      gamemode.enable = true;
    };
  };
}
