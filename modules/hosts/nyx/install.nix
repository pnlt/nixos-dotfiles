{inputs, ...}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    apps.install-nyx.program = pkgs.writeShellApplication {
      name = "install-nyx";
      runtimeInputs = [inputs.disko.packages.${system}.disko];
      text = builtins.readFile ./install.sh;
    };
  };
}
