{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-KINGSTON_SNV2S500G_50026B76868A14B9";
    content = {
      type = "gpt";
      partitions = {
        boot = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            extraArgs = ["-n" "boot"];
          };
        };
        swap = {
          size = "4G";
          content = {
            type = "swap";
            extraArgs = ["-L" "swap"];
          };
        };
        nixos = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            extraArgs = ["-L" "nixos"];
          };
        };
      };
    };
  };
}
