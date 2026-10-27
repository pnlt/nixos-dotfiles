{
  mkAgentKit,
  config,
  pkgs,
  lib,
  ...
}: let
  kit = mkAgentKit {};
  sources = builtins.mapAttrs (_: pkgs.fetchFromGitHub) (lib.importJSON ./plugins-sources.json);
in {
  imports = [
    ./hooks.nix
  ];

  # not `programs.claude-code.plugins`: its per-entry links put mod files
  # outside the plugin directory, which claude refuses. Copied, not linked:
  # claude reloads a mod whenever a watched file's ctime moves, and with
  # auto-optimise-store every dirty-tree flake copy hardlinks the same inodes.
  # (luisquin also installs his `phone` mod here; phone is not ported.)
  home.activation.claudeMods = let
    skills = "${config.programs.claude-code.configDir}/skills";
    stamps = "${config.xdg.stateHome}/claude-mods";
  in
    lib.hm.dag.entryAfter ["linkGeneration"] ''
      claudeMod() {
        local dst="${skills}/$1" stamp="${stamps}/$1"
        [ "$(cat "$stamp" 2>/dev/null)" = "$2" ] && [ -d "$dst" ] && [ ! -L "$dst" ] && return
        run rm -rf "$dst.new"
        run cp -rL --no-preserve=mode,ownership "$2" "$dst.new"
        run rm -rf "$dst"
        run mv "$dst.new" "$dst"
        [[ -v DRY_RUN ]] || printf '%s\n' "$2" > "$stamp"
      }
      run mkdir -p "${skills}" "${stamps}"
      claudeMod chat-clean ${sources.chat-clean}
    '';

  xdg.configFile."ccstatusline/settings.json" = let
    settingsJson = builtins.fromJSON (builtins.readFile ./ccstatusline-settings.json);
  in {
    text = builtins.toJSON (settingsJson
      // {
        installation = {
          method = "pinned";
          installedVersion = pkgs.llm-agents.ccstatusline.version;
        };
      });
  };

  programs.claude-code = {
    enable = true;
    package = pkgs.llm-agents.claude-code;
    enableMcpIntegration = true;
    mcpServers = kit.mkMcpServers {};

    hooks = {
      "rtk-rewrite.sh" = let
        upstream = builtins.readFile "${pkgs.rtk}/share/rtk/hooks/claude/rtk-rewrite.sh";
        autoAllow = lib.concatMapStrings (line: "        ${line}\n") [
          ''"permissionDecision": "allow",''
          ''"permissionDecisionReason": "RTK auto-rewrite",''
        ];
        rewritten = "EXIT_CODE=$?\n";
        # a worktree-isolated agent's git calls are refused once rtk wraps them
        isolatedGit = ''
          case "$(jq -r '.cwd // empty' <<<"$INPUT")" in
            */.claude/worktrees/*) case "$REWRITTEN" in *"rtk git"*) exit 0 ;; esac ;;
          esac
        '';
      in
        assert lib.assertMsg (lib.hasInfix autoAllow upstream) "rtk-rewrite.sh changed; re-check its auto-allow branch";
        assert lib.assertMsg (lib.hasInfix rewritten upstream) "rtk-rewrite.sh changed; re-check where EXIT_CODE is read";
          builtins.replaceStrings [autoAllow rewritten] ["" (rewritten + isolatedGit)] upstream;
    };

    marketplaces = {
      inherit (sources) better-claude claude-plugins-official claude-blindfold oikon48;
    };

    context = ''
      ${kit.memories}

      ${kit.claudeMemories}
    '';

    # https://code.claude.com/docs/en/settings#available-settings
    settings = {
      enabledPlugins = {
        "blindfold@claude-blindfold" = true;
        "image-preview@better-claude" = true;
        "prompt-rail@oikon48" = true;
        "rust-analyzer-lsp@claude-plugins-official" = true;
        # luisquin also enables swift-lsp; it needs sourcekit-lsp (Xcode side).
      };

      # luisquin runs "opus" + effort "high" on a bigger plan. On Pro, Sonnet
      # stretches the 5-hour/weekly limits much further. Switch per session
      # with `/model opus` or `/model opusplan` (plan with Opus, code with
      # Sonnet) when a task deserves it, or change the default here.
      model = "sonnet";
      effortLevel = "high";
      language = "english";
      cleanupPeriodDays = 90;
      tui = "fullscreen";
      showThinkingSummaries = true;
      autoCompactWindow = 200000;

      env = {
        # Masks secrets out of every Bash tool call's stdout/stderr.
        "CLAUDE_CODE_SHELL_PREFIX" = lib.getExe pkgs.redact-secrets;
        # Agent teams run several Claude sessions at once and drain Pro quota
        # fast. Set to "1" to match luisquin.
        "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS" = "0";
        # Updates come from `nix flake update llm-agents`, not the CLI.
        "DISABLE_AUTOUPDATER" = "1";
      };

      attribution = false;
      skipDangerousModePermissionPrompt = true;

      # luisquin wraps this in `strikedddd statusline …` (private input).
      statusLine = {
        "type" = "command";
        "command" = lib.getExe pkgs.llm-agents.ccstatusline;
        "padding" = 0;
        "refreshInterval" = 5;
      };

      permissions = kit.mkAgentPermissions "claude" {};
    };
  };

  home.packages = [pkgs.jq];
}
