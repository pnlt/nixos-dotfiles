{...}: {
  flake.modules.homeManager.dev = {pkgs, ...}: let
    # UnityShaderCompiler links libtinfo.so.6; nixpkgs only ships it as a symlink to
    # libncursesw.so.6, and the FHS ld.so.cache indexes libraries by SONAME
    libtinfo = pkgs.runCommand "libtinfo-soname" {nativeBuildInputs = [pkgs.patchelf];} ''
      install -Dm755 ${pkgs.ncurses.out}/lib/libncursesw.so.6 $out/lib/libtinfo.so.6
      patchelf --set-soname libtinfo.so.6 $out/lib/libtinfo.so.6
    '';
  in {
    home.packages = with pkgs; [
      (unityhub.override {extraLibs = _: [libtinfo ocl-icd];})
      jetbrains.rider
    ];
  };
}
