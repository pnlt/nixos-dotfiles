{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    coreutils
    binutils
    ripgrep
    tree
    lsof
    wget
    eza
    fd
  ];
}
