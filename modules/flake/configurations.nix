{
  inputs,
  config,
  withSystem,
  ...
}: let
  inherit (config) meta;
  system = "x86_64-linux";
  pkgs = withSystem system ({pkgs, ...}: pkgs);

  specialArgs = {
    inherit inputs system;
    libx = import ../../lib {inherit pkgs;};
    isWayland = true;
  };
  configArgs = specialArgs // {inherit (meta) host user nix;};
in {
  flake.nixosConfigurations.${meta.host.name} = inputs.nixpkgs.lib.nixosSystem {
    inherit pkgs;

    modules =
      [
        inputs.nix-index-database.nixosModules.nix-index
        inputs.lanzaboote.nixosModules.lanzaboote
        inputs.nyx-terminal.nixosModules.default
        # Declares home-manager.* options that standalone HM reads through nixosConfig
        inputs.home-manager.nixosModules.default
        inputs.sops-nix.nixosModules.sops
        inputs.fcitx5-lotus.nixosModules.fcitx5-lotus
        inputs.preservation.nixosModules.preservation
        ../../pkgs/nixos-modules
        "${inputs.luisquin-config}/pkgs/ttygate/nixos-modules"
        (../../system/hosts + "/${meta.host.name}")
      ]
      ++ (with config.flake.modules.nixos; [
        nix
        core
        boot
        fs
        hardware
        input
        shell
        security
        network
        secrets
      ]);
    specialArgs =
      configArgs
      // {
        hmConfig = config.flake.homeConfigurations.${meta.user.alias}.config;
      };
  };

  flake.homeConfigurations.${meta.user.alias} = inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;

    modules =
      [
        inputs.nyx-terminal.homeModules.default
        inputs.agentic-flake.homeModules.default
        inputs.encore.homeModules.default
        inputs.techdebt-cli.homeModules.default
        inputs.hex.homeManagerModules.hex
        inputs.direnv-instant.homeModules.default
        ../../pkgs/hm-modules
        "${inputs.luisquin-config}/pkgs/phone/hm-modules"
        ../../home/options
        (../../home/profiles + "/${meta.user.alias}")
      ]
      ++ (with config.flake.modules.homeManager; [
        hardware
        shell
        terminal
      ]);
    extraSpecialArgs =
      configArgs
      // {
        nixosConfig = config.flake.nixosConfigurations.${meta.host.name}.config;
      };
  };
}
