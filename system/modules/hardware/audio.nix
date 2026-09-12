{pkgs, ...}: {
  security.rtkit.enable = true;

  hardware.alsa = {
    enablePersistence = true;
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  environment.systemPackages = with pkgs; [
    alsa-utils
  ];
}
