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
    # roborev = {
    #   url = "github:roborev-dev/roborev";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
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
    nyx-terminal = {
      url = "path:/home/pnlt/projects/nyx-terminal";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
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
      inherit (metadata) host user nix;
      system = defaultSystem;
      # isTiling = true;
      isWayland = true;
    };
    # NixOS module list (system-wide)
    nixosModules = [
      inputs.flake-programs-sqlite.nixosModules.programs-sqlite
      inputs.nyx-terminal.nixosModules.default

      # First-party package NixOS modules (auto-discovers pkgs/*/nixos-modules)
      ./pkgs/nixos-modules

      (./system/hosts + "/${metadata.host.name}")

      home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = specialArgs;
          users.${metadata.user.alias} = {
            imports = [
              inputs.nyx-terminal.homeModules.default
              inputs.agentic-flake.homeModules.default

              # First-party package HM modules
              ./pkgs/hm-modules

              ./home/options
              ./home/profiles/${metadata.user.alias}
            ];
          };
          backupFileExtension = "backup";
        };
      }
    ];
  in
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      inherit systems;

      perSystem = {system, ...}: let
        pkgs' = mkPkgs system;
      in {
        # Expose first-party packages: nix build .#cliphizt etc.
        packages = import ./pkgs pkgs';
      };

      flake = {
        nixosConfigurations.${metadata.host.name} = nixpkgs.lib.nixosSystem {
          inherit pkgs;
          system = defaultSystem;
          modules = nixosModules;
          specialArgs = specialArgs;
        };
      };
    };
}
