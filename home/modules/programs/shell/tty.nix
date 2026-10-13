{pkgs, ...}: {
  home.packages = with pkgs.myScripts; [
    sys-brightness
    sys-sound
  ];
}
