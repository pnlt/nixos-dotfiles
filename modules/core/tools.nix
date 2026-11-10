{...}: {
  flake.modules.nixos.core = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      coreutils
      binutils
      ripgrep
      tree
      lsof
      wget
      eza
      fd
      dust
      procs
      xcp
      hexyl
      bandwhich
    ];
  };
}
