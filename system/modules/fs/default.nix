{pkgs, ...}: {
  boot.tmp.cleanOnBoot = true;

  services = {
    udisks2.enable = true;
    fstrim.enable = true;
  };

  environment.systemPackages = with pkgs; [
    gparted
  ];
}
