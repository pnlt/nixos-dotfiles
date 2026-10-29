{
  config,
  user,
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

      # description optional
      # description = user.alias;

      extraGroups = [
        "networkmanager"
        "wheel"
        # "video"
        # "audio"
        # "input"
        # "dialout"   # serial devices / Arduino
        # "wireshark" # only if you install wireshark and need capture
      ];
    };
  };
}
