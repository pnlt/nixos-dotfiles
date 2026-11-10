{...}: {
  flake.modules.homeManager.studio = {pkgs, ...}: {
    home.packages = [
      pkgs.shotcut
      pkgs.ffmpeg
    ];

    programs.obs-studio = {
      enable = true;

      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-pipewire-audio-capture
        obs-vaapi #optional AMD hardware acceleration
      ];
    };
  };
}
