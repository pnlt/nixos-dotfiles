{
  inputs,
  pkgs,
  ...
}: {
  home.packages = [
    inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
