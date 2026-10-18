{pkgs, ...}: {
  imports = [
    ./clipboard.nix
    ./niri.nix
    ./fonts
  ];

  programs.dconf.enable = true;
  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v24n.psf.gz";
    packages = [pkgs.terminus_font];
  };

  services = {
    # graphical-desktop.nix turns speechd on by mkDefault for any desktop. no
    # screen reader here, and its module probes leave unreaped children behind.
    speechd.enable = false;
    getty.autologinUser = "pnlt";
  };
}
