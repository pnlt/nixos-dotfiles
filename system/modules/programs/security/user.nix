{
  user,
  pkgs,
  lib,
  ...
}: {
  users = {
    defaultUserShell = pkgs.zsh;

    users.${user.alias} = {
      isNormalUser = true;
      home = "/home/${user.alias}";
      shell = pkgs.zsh;

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
