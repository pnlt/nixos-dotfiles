{
  lib,
  pkgs,
  ...
}: {
  environment.systemPackages = [pkgs.sbctl];

  systemd.services.systemd-bless-boot.enable = false;

  boot.loader.systemd-boot = {
    enable = lib.mkForce false;
    consoleMode = "max";
  };

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    configurationLimit = 10;
  };
}
