{pkgs, ...}: {
  imports = [
    ./ephemeral.nix
    ./persistence.nix
  ];

  boot.tmp.cleanOnBoot = true;

  services = {
    udisks2.enable = true;
    fstrim.enable = true;
  };

  environment.systemPackages = with pkgs; [
    gparted
  ];
}
