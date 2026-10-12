{
  description = "Infrastructure for NixOS, Flakes and home manager ❄️";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-extra = {
      url = "github:0xc000022070/nixpkgs-extra";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
      };
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    systems.url = "github:nix-systems/default";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "rust-overlay";
      };
    };
    encore = {
      url = "github:encoredev/encore-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake/beta";
      inputs = {
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
      };
    };
    ghostty = {
      url = "github:ghostty-org/ghostty/tip";
      inputs = {
        flake-compat.follows = "";
        home-manager.follows = "home-manager";
        systems.follows = "systems";
        nixpkgs.follows = "nixpkgs";
      };
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    bun2nix = {
      url = "github:nix-community/bun2nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        flake-parts.follows = "flake-parts";
        bun2nix.follows = "bun2nix";
        treefmt-nix.follows = "bun2nix/treefmt-nix";
      };
    };
    agentic-flake = {
      url = "github:0xc000022070/agentic-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    hermes-agent = {
      url = "github:NousResearch/hermes-agent";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };
    flake-programs-sqlite = {
      url = "github:wamserma/flake-programs-sqlite";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.follows = "flake-utils";
      };
    };
    techdebt-cli = {
      url = "github:0xc000022070/techdebt-cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nyx-terminal = {
      url = "github:pnlt/nyx-terminal";
    };
  };

  outputs = inputs @ {
    home-manager,
    nixpkgs,
    ...
  }: let
    defaultSystem = "x86_64-linux";
    systems = [defaultSystem];

    # Off nixpkgs.lib so overlays can use lib without recursing through pkgs
    metadata =
      (import ./lib/metadata.nix {inherit (nixpkgs) lib;})
      .mkMetadata ./flake.toml "pnlt@nyx";

    mkPkgs = system: let
      config = {
        allowBroken = false;
        allowUnfree = true;
        # android_sdk.accept_license = true;
      };
    in
      import nixpkgs {
        inherit config;
        localSystem.system = system;
        overlays =
          import ./overlays/inputs.nix {
            inherit inputs system;
          }
          ++ [
            (final: _prev: import ./pkgs final)
          ]
          ++ import ./overlays/nixpkgs.nix {
            inherit inputs system;
            inherit (metadata) host;
          };
      };

    pkgs = mkPkgs defaultSystem;

    libx = import ./lib {
      inherit pkgs;
    };

    specialArgs = {
      inherit inputs libx;
      system = defaultSystem;
      # isTiling = true;
      isWayland = true;
    };
    configArgs =
      specialArgs
      // {
        inherit (metadata) host user nix;
      };

    # NixOS module list (system-wide)
    nixosModules = [
      inputs.flake-programs-sqlite.nixosModules.programs-sqlite
      inputs.lanzaboote.nixosModules.lanzaboote
      inputs.nyx-terminal.nixosModules.default
      inputs.home-manager.nixosModules.default
      ./pkgs/nixos-modules
      (./system/hosts + "/${metadata.host.name}")
    ];

    homeModules = [
      inputs.nyx-terminal.homeModules.default
      inputs.agentic-flake.homeModules.default
      inputs.encore.homeModules.default
      inputs.techdebt-cli.homeModules.default
      ./pkgs/hm-modules
      ./home/options
      (./home/profiles + "/${metadata.user.alias}")
    ];
  in
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      inherit systems;

      perSystem = {system, ...}: let
        pkgs = mkPkgs system;
      in {
        packages = import ./pkgs pkgs;
      };

      flake = rec {
        nixosConfigurations."${metadata.host.name}" = nixpkgs.lib.nixosSystem {
          inherit pkgs;

          modules = nixosModules;
          specialArgs =
            configArgs
            // {
              hmConfig = homeConfigurations."${metadata.user.alias}".config;
            };
        };

        homeConfigurations."${metadata.user.alias}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = homeModules;
          extraSpecialArgs =
            configArgs
            // {
              system = defaultSystem;
              nixosConfig = nixosConfigurations."${metadata.host.name}".config;
            };
        };
      };
    };
}
