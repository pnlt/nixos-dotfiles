{
  imports = [
    ./options.nix
    ./android.nix
    ./avds.nix
  ];

  programs.phone = {
    enable = true;
    pools.android = ["galaxy-s26-plus"];
  };
}
