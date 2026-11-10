{...}: {
  flake.modules.nixos.mobile = {pkgs, ...}: {
    # gradle-fetched aapt2 and the sdk's prebuilt binaries are dynamically linked
    programs.nix-ld.enable = true;

    environment.systemPackages = [pkgs.android-tools];
  };
}
