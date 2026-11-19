{inputs, ...}: {
  flake.modules.homeManager.agents = {pkgs, ...}: let
    inherit (inputs.agentic-flake.lib) mkSkill mkInlineSkill;
  in {
    # Installs every skill below into ~/.agents/skills ("common") and
    # ~/.claude/skills ("claude").
    #
    # Dropped from luisquin's list (tied to his hardware/accounts): ee-workbench,
    # pen-design, linear-*, android-firmware-lab, jetson-nixos, mobile-nixos-port.
    programs.agents = {
      enable = true;

      defaultScopes = ["common" "claude"];

      skills = with pkgs.agent-skills; [
        (mkInlineSkill {
            "nixgrep" = {
              description = "Find /nix/store paths by name with `nixgrep <search-term>`, covering a package's outputs, its .drv files and companion derivations such as go-modules. Use it instead of `ls /nix/store | grep`. Prints store basenames, one per line, without the /nix/store/ prefix.";
              tags = ["utils"];
              content = ''
                # Quick Reference

                $ nixgrep nao
                q0bfqrchwnip1n48idwmsblrqx3rds37-nao
                bsia93f0mzdrrdxigdmc48i9zcg2j4j7-nao-3.3.0
                298vl82bfm4939fd0clmw1m1hzid675j-nao-3.3.0-go-modules
                7gr2qa7saimqvnhl8nwgvlaf9fid25g9-nao-3.3.0-go-modules.drv
                rwajk54dm1wa3iqg0mahpv7bxhjyapfk-nao-3.3.0-go-modules.drv
              '';
            };
          } {
            plugins = ["nixgrep"];
          })
        (mkInlineSkill {
            "phone-skill" = {
              description = "Drive Android phones, emulators (AVDs) and iOS simulators, local or on a remote Mac, with the `phone` CLI instead of raw adb, emulator, avdmanager, xcrun simctl or ssh. Boot, pick a device, snapshot the screen, tap, swipe, type, wait, screenshot, record, install, launch, open deep links, reverse ports.";
              tags = ["mobile"];
              content = builtins.readFile "${inputs.luisquin-config}/home/modules/programs/development/agents/skills/phone.md";
            };
          } {
            plugins = ["phone-skill"];
          })
        (mkSkill {src = ./skills;} {
          plugins = ["nix-patch" "nix-triage" "squad" "dev-flow"];
        })
        (anthropics.skills {
          prefix = "anthropics-";
          plugins = ["frontend-design"];
        })
        (daffy0208.ai-dev-standards {
          plugins = [
            "mobile-developer"
          ];
        })
        (mkSkill {
            src = pkgs.fetchFromGitHub {
              owner = "cursor";
              repo = "plugins";
              rev = "8ecfb19f844b67a4bc7af7f66c366d57bc7b6d2b";
              hash = "sha256-/ubdPfVeNY1RxHIzH/+n3M15SFQZvyt0uR8md3bXNxA=";
              rootDir = "pstack/skills";
            };
          } {
            plugins = [
              "unslop"
            ];
          })
        # Teaches the agent herdr's CLI (panes, tabs, waiting on other agents).
        (mkSkill {src = pkgs.llm-agents.herdr.src;} {
          plugins = ["herdr"];
        })
        # Required: the diff-review PostToolUse hook tells claude to load it.
        (mkSkill {
            src = pkgs.fetchFromGitHub {
              owner = "ciembor";
              repo = "agent-rules-books";
              rev = "893a88a6fce3a80c565bf39ac65021b43a8b2990";
              sha256 = "sha256-ZdYHWG/4ueNJXjUABAGU/AgzhS56eN5ZH5DU7YLlY3k=";
            };
          } {
            plugins = ["refactoring-guru"];
          })
        (mkSkill {
            src = pkgs.fetchFromGitHub {
              owner = "0xc000022070";
              repo = "skills";
              rev = "95c377d33d72cce933ebbf61d82ddcda1446956b";
              sha256 = "sha256-Jzwkcfv2lwQAYwiR3Mkwo2VsIknRRIjOsvfUIt+ZptI=";
            };
          } {
            plugins = [
              "commit"
              "qa-fleet"
            ];
          })
        (mkSkill {
            src = pkgs.fetchFromGitHub {
              owner = "leonxlnx";
              repo = "taste-skill";
              rev = "f6b76575f949707b4e3c37cd86cb44b0b98643e8";
              hash = "sha256-7w2pcrS5g3ACXiAoJL3oe+hiVy+aDmUnx3PxeRZ9rVg=";
            };
          } {
            plugins = ["taste-skill"];
          })
        (mkSkill {
            src = pkgs.applyPatches {
              name = "ui-ux-pro-max-skill";
              src = pkgs.fetchFromGitHub {
                owner = "nextlevelbuilder";
                repo = "ui-ux-pro-max-skill";
                rev = "6ae86f61f520d6ca229d2f40e070410638c908c5";
                hash = "sha256-e/FyuIeBDFUnw9ofEyAPJZm0dV7eOhjmCya627TXKDk=";
                rootDir = ".claude/skills";
              };
              postPatch = ''
                substituteInPlace ui-ux-pro-max/SKILL.md \
                  --replace-fail '"''${CLAUDE_PLUGIN_ROOT}/.claude/skills/ui-ux-pro-max/' "\"$out/ui-ux-pro-max/"
              '';
            };
          } {
            plugins = ["ui-ux-pro-max"];
          })
      ];
    };
  };
}
