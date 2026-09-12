{
  config,
  sys,
  ...
}: let
  flakeDir = config.programs.hostcmd.flakeDir;
  host = config.networking.hostName;
in {
  programs.hostcmd = {
    enable = true;

    # Optional later:
    # ntfy.baseUrl = "https://ntfy.sh";  # or your own server
    # ntfy.topic = "nyx";

    commands = {
      update = {
        description = "Rebuild and switch NixOS (includes Home Manager)";

        steps = sys.withNotify {
          successTitle = "Nyx update finished";
          successBody = "NixOS configuration applied.";
          failureTitle = "Nyx update failed";
          failureBody = "Check the terminal output.";
        } (sys.compose "update" ["system"]);

        subcommands = {
          system = {
            description = "nixos-rebuild switch";
            steps =
              sys.withNotify {
                successTitle = "Nyx system update finished";
                successBody = "nixos-rebuild completed.";
                failureTitle = "Nyx system update failed";
                failureBody = "nixos-rebuild did not complete successfully.";
              } [
                sys.requireSudo
                (sys.run {
                  workdir = flakeDir;
                  cmd = "sudo nixos-rebuild switch --flake .#${host}";
                })
              ];
          };
        };
      };

      style = {
        description = "Format all .nix files with alejandra";
        steps = [
          (sys.run {
            workdir = flakeDir;
            cmd = "alejandra .";
          })
        ];
      };

      clean = {
        description = "Garbage-collect old generations and optional caches";
        steps = [
          sys.requireSudo
          (sys.run "sudo nix-collect-garbage --delete-old")
          (sys.run "nix-collect-garbage -d")
          (sys.run "nix-store --optimise")
          # Only run if the tool exists on your system:
          (sys.runIfExists "docker" "docker system prune --volumes -f")
          (sys.runIfExists "kondo" "kondo -a")
          ''
            if [ -d "$HOME/.npm/_npx" ]; then
              rm -rf "$HOME/.npm/_npx"
              echo "removed ~/.npm/_npx"
            fi
          ''
        ];
      };
    };
  };
}
