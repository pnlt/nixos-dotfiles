{
  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = ["defaults" "size=4G" "mode=755"];
    };

    "/nix" = {
      device = "/persist/nix";
      fsType = "none";
      options = ["bind"];
      depends = ["/persist"];
    };

    "/tmp" = {
      device = "/persist/tmp";
      fsType = "none";
      options = ["bind"];
      depends = ["/persist"];
    };
  };
}
