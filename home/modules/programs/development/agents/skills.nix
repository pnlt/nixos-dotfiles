{
  inputs,
  pkgs,
  ...
}: let
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
        plugins = [
          "pdf"
          "pptx"
          "frontend-design"
        ];
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
            rev = "ecc249f1e306fc64ddf83c7bed16cacf7c2239db";
            hash = "sha256-okjUS0AVmgoQfCO3nzzqjL1PnZ8X3r8wjtz5SwrFse0=";
          };
        } {
          plugins = [
            "unslop"
          ];
        })
      (vercel-labs.skills {
        plugins = [
          "find-skills"
        ];
      })
      (mkSkill {
          src = pkgs.fetchFromGitHub {
            owner = "mattpocock";
            repo = "skills";
            rev = "a496f5513d4a4cf889bc48e189e579f4b0bdf6aa";
            hash = "sha256-nxTjN6ePfumLCJ77zw4kdMwPeOHU2TztFZPOiMr3zGw=";
            rootDir = "skills/engineering";
          };
        } {
          plugins = [
            "improve-codebase-architecture"
            "codebase-design"
            "domain-modeling"
          ];
        })
      (mkSkill {
          src = pkgs.fetchFromGitHub {
            owner = "mattpocock";
            repo = "skills";
            rev = "a496f5513d4a4cf889bc48e189e579f4b0bdf6aa";
            hash = "sha256-8xDSNA3dk6AyfiKg8XAwmb9uQMqaCI4m8ERi4TBVQ28=";
            rootDir = "skills/productivity";
          };
        } {
          plugins = ["grilling"];
        })
      (wshobson.agents {
        plugins = [
          "typescript-advanced-types"
          "e2e-testing-patterns"
        ];
      })
      # Teaches the agent herdr's CLI (panes, tabs, waiting on other agents).
      (mkSkill {src = pkgs.llm-agents.herdr.src;} {
        plugins = ["herdr"];
      })
      (mkSkill {
          src = pkgs.fetchFromGitHub {
            owner = "aia-11-hn-mib";
            repo = "mib-mockinterviewaibot";
            rev = "50ccfb29063bb6d64d049fc982ca53424d0ca3b1";
            sha256 = "sha256-FdlbFVFSEtiFMiuisSLmgibFCro17jo3TjS9Oibx8F0=";
          };
        } {
          plugins = ["imagemagick"];
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
            rev = "02e5581607a674584b6510677ec3562a7af5a34e";
            sha256 = "sha256-xg+a9DqDtNRts9X4+yYvT5RKsYbTV9Y7quT1WbLIZfg=";
          };
        } {
          plugins = [
            "commit"
            "socratic-debate"
            "counter-attack"
            "qa-fleet"
          ];
        })
      (mkSkill {
          src = pkgs.fetchFromGitHub {
            owner = "leonxlnx";
            repo = "taste-skill";
            rev = "6010f91a9935f1c167dfc500fb1a475681892e6b";
            hash = "sha256-25Hc9DiKiDSq+Ae3bTwv9nnk7KziP0cp3Q8srpXE47U=";
          };
        } {
          plugins = ["taste-skill"];
        })
      (mkSkill {
          src = pkgs.fetchFromGitHub {
            owner = "hyperb1iss";
            repo = "hyperskills";
            rev = "a0e30e791c5a9ef65f438a24b6ea7bffb912ac70";
            hash = "sha256-Rl0BBK/Hnf7xOwWvNMqkmm64sRnMEtl0+walbkq79P8=";
            rootDir = "skills";
          };
        } {
          plugins = ["tui-design"];
        })
      (mkSkill {
          src = pkgs.applyPatches {
            name = "ui-ux-pro-max-skill";
            src = pkgs.fetchFromGitHub {
              owner = "nextlevelbuilder";
              repo = "ui-ux-pro-max-skill";
              rev = "076a2b3a31394ad788afaa71f55d0bf789e7b3ec";
              hash = "sha256-oUr1p0GuTH5nXegrf+3Q4qOWUCDOhEEEEpcGaRBvepE=";
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
}
