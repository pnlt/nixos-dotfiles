{config, ...}: let
  inherit (config.meta) user;
in {
  flake.modules.nixos.security = {
    config,
    pkgs,
    ...
  }: {
    users = {
      defaultUserShell = pkgs.zsh;
      # Without this, hashedPasswordFile only applies when the user is first created.
      mutableUsers = false;

      users.${user.alias} = {
        isNormalUser = true;
        home = "/home/${user.alias}";
        shell = pkgs.zsh;
        hashedPasswordFile = config.sops.secrets."users/${user.alias}-password-hash".path;

        extraGroups = [
          "networkmanager"
          "wheel"
        ];
      };
    };
  };
}
