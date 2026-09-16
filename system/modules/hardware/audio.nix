{pkgs, ...}: {
  security.rtkit.enable = true;
  programs.noisetorch.enable = true;

  services = {
    pulseaudio.enable = 0 != 0;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };
  hardware.alsa = {
    enablePersistence = true;
  };

  environment.systemPackages = with pkgs; [
    pulseaudio
    alsa-utils
  ];
}
