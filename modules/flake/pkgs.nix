{inputs, ...}: {
  perSystem = {
    system,
    pkgs,
    ...
  }: {
    _module.args.pkgs = import inputs.nixpkgs {
      config = {
        allowBroken = false;
        allowUnfree = true;
        android_sdk.accept_license = true;
      };
      localSystem.system = system;
      overlays =
        import ../../overlays/inputs.nix {inherit inputs system;}
        ++ [(final: _prev: import ../../pkgs final)]
        ++ import ../../overlays/nixpkgs.nix;
    };

    packages = import ../../pkgs pkgs;
  };
}
