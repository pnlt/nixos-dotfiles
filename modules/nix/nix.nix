{
  config,
  inputs,
  ...
}: let
  inherit (config.meta) user;
in {
  flake.modules.nixos.nix = {pkgs, ...}: {
    services.harmonia.gc = {
      enable = true;
      automatic = true;
      dates = ["daily"];
      deleteOlderThan = "3d";
      keepRecent = "1d";
    };

    nix = {
      optimise = {
        automatic = true;
        dates = ["13:00"]; # I normally lunch at this hour
      };

      # https://nixos.org/manual/nix/stable/command-ref/conf-file.html
      settings = rec {
        keep-outputs = true;
        warn-dirty = false;
        download-attempts = 3;
        experimental-features = ["nix-command" "flakes"];
        trusted-users = ["root"];
        allowed-users = ["root" "${user.alias}"];
        max-jobs = 2;
        # Threads per build; 0 (default) lets 6 rustc builds take all 12 threads each and OOM.
        cores = 6;
        min-free = 10000000000; # 10GB
        min-free-check-interval = 30;
        # https://nix.dev/recipes/faq#what-to-do-if-a-binary-cache-is-down-or-unreachable
        fallback = true;

        substituters = [
          "https://cache.nixos.org"
          "https://cache.numtide.com"
        ];
        trusted-public-keys = [
          "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
        ];
      };

      nixPath = ["nixpkgs=flake:nixpkgs"];
    };

    systemd.services.nix-cleanup-gcroots = {
      startAt = "weekly";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = [
          "${pkgs.findutils}/bin/find /nix/var/nix/gcroots/auto /nix/var/nix/gcroots/per-user -type l -mtime +30 -delete"
          "${pkgs.findutils}/bin/find /nix/var/nix/temproots -type f -mtime +10 -delete"
          "${pkgs.findutils}/bin/find /nix/var/nix/gcroots -xtype l -delete"
        ];
      };
    };
    systemd.timers.nix-cleanup-gcroots.timerConfig.Persistent = true;

    programs.nix-index-database.comma.enable = true;

    environment = {
      systemPackages = with pkgs; [
        nix-output-monitor
        nix-prefetch-git
        cached-nix-shell
        deadnix
        statix
        nurl
        nil # lsp
        nvd # package diff
        nix-update
        nix-fast-build
        inputs.nix-diff-rs.packages.${pkgs.stdenv.hostPlatform.system}.default
        inputs.nix-tree-rs.packages.${pkgs.stdenv.hostPlatform.system}.default

        nixpkgs-review
        nixpkgs-lint

        # Formatters
        nixpkgs-fmt
        alejandra
      ];

      shellAliases = {
        nix-shell = "cached-nix-shell --command zsh";
        ns = "cached-nix-shell --command zsh";
      };

      variables.NIXPKGS_ALLOW_UNFREE = "1";
    };
  };
}
