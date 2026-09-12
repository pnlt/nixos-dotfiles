{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.programs.hostcmd;

  defaultIcon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";

  # --- helpers baked into the generated CLI ---
  sys = {
    run = cmd: let
      isAttr = builtins.isAttrs cmd;
      workdir =
        if isAttr
        then cmd.workdir or "."
        else ".";
      command =
        if isAttr
        then cmd.cmd
        else cmd;
    in ''
      (
        cd ${workdir}
        printf "\n\e[38;2;112;112;112m(${workdir})\033[0;32m ${command}\033[0m\n"
        ${command}
      ) || exit "$?"
    '';

    requireSudo = ''
      if [ "$(id -u)" -ne 0 ]; then sudo -v || exit "$?"; fi
    '';

    # Run only if the binary exists (for optional clean tools)
    runIfExists = bin: cmd: ''
      if command -v ${bin} >/dev/null 2>&1; then
        ${sys.run cmd}
      else
        printf "\n\e[38;2;112;112;112mskip (no ${bin})\033[0m\n"
      fi
    '';

    compose = cmdName: subNames:
      builtins.concatMap (
        subName:
          if cfg.commands.${cmdName}.subcommands ? ${subName}
          then cfg.commands.${cmdName}.subcommands.${subName}.steps
          else []
      )
      subNames;

    withNotify = {
      image ? defaultIcon,
      successTitle,
      successBody,
      failureTitle,
      failureBody,
    }: steps: let
      ntfyHost = cfg.ntfy.baseUrl;
      ntfyTopic = cfg.ntfy.topic;

      desktopOk = ''${lib.getExe pkgs.libnotify} -a "nyx" -i ${lib.escapeShellArg image} ${lib.escapeShellArg successTitle} ${lib.escapeShellArg successBody} 2>/dev/null || true'';
      desktopErr = ''${lib.getExe pkgs.libnotify} -a "nyx" -i ${lib.escapeShellArg image} ${lib.escapeShellArg failureTitle} ${lib.escapeShellArg failureBody} 2>/dev/null || true'';

      ntfyOk =
        if ntfyHost == ""
        then "true"
        else ''curl -fsS -H "Title: ${successTitle}" -H "Tags: white_check_mark" -d ${lib.escapeShellArg successBody} ${lib.escapeShellArg "${ntfyHost}/${ntfyTopic}"} >/dev/null 2>&1 || true'';
      ntfyErr =
        if ntfyHost == ""
        then "true"
        else ''curl -fsS -H "Title: ${failureTitle}" -H "Tags: x" -H "Priority: 5" -d ${lib.escapeShellArg failureBody} ${lib.escapeShellArg "${ntfyHost}/${ntfyTopic}"} >/dev/null 2>&1 || true'';

      inner = concatStringsSep "\n" steps;
    in [
      ''
        __nyx_status=0
        (
          set +e
          ${inner}
          exit $?
        )
        __nyx_status=$?
        if [ "$__nyx_status" -eq 0 ]; then
          ${desktopOk}
          ${ntfyOk}
        else
          ${desktopErr}
          ${ntfyErr}
          exit "$__nyx_status"
        fi
      ''
    ];
  };

  renderHelp = let
    cmdLines =
      mapAttrsToList (
        name: c: "  ${name}\t${c.description}"
      )
      cfg.commands;
  in ''
    echo "${config.networking.hostName} — host commands"
    echo ""
    echo "Usage: ${config.networking.hostName} <command> [subcommand]"
    echo ""
    echo "Commands:"
    ${concatStringsSep "\n" (map (l: "echo \"${l}\"") cmdLines)}
    echo "  help\tShow this help"
  '';

  renderCommand = name: c: let
    mainSteps =
      if c.steps != []
      then concatStringsSep "\n" c.steps
      else "echo \"No steps for ${name}\"; exit 1";

    subCases =
      mapAttrsToList (
        subName: sub: ''
          ${subName})
            ${concatStringsSep "\n" sub.steps}
            ;;
        ''
      )
      c.subcommands;
  in ''
    ${name})
      sub="''${1:-}"
      if [ -n "$sub" ] && [ "$sub" != "" ]; then
        shift || true
        case "$sub" in
          ${concatStringsSep "\n" subCases}
          *)
            echo "Unknown subcommand: ${name} $sub"
            exit 1
            ;;
        esac
      else
        ${mainSteps}
      fi
      ;;
  '';

  cliScript = pkgs.writeShellScriptBin config.networking.hostName ''
    set -euo pipefail

    COMMAND="''${1:-}"
    shift || true

    case "$COMMAND" in
      ${concatStringsSep "\n" (mapAttrsToList renderCommand cfg.commands)}

      help|-h|--help|"")
        ${renderHelp}
        ;;

      *)
        echo "Unknown command: $COMMAND"
        ${renderHelp}
        exit 1
        ;;
    esac
  '';
in {
  options.programs.hostcmd = {
    enable = mkEnableOption "Declarative host CLI named after the machine";

    flakeDir = mkOption {
      type = types.str;
      default = "$HOME/nixos-dotfiles";
      description = "Path to the flake repository (shell-expanded).";
    };

    ntfy = {
      baseUrl = mkOption {
        type = types.str;
        default = "";
        example = "https://ntfy.example.com";
        description = "Optional ntfy base URL. Empty = desktop notify only.";
      };
      topic = mkOption {
        type = types.str;
        default = "nyx";
        description = "ntfy topic when baseUrl is set.";
      };
    };

    commands = mkOption {
      type = types.attrsOf (types.submodule ({...}: {
        options = {
          description = mkOption {
            type = types.str;
            default = "";
          };
          steps = mkOption {
            type = types.listOf types.lines;
            default = [];
          };
          subcommands = mkOption {
            type = types.attrsOf (types.submodule ({...}: {
              options = {
                description = mkOption {
                  type = types.str;
                  default = "";
                };
                steps = mkOption {
                  type = types.listOf types.lines;
                  default = [];
                };
              };
            }));
            default = {};
          };
        };
      }));
      default = {};
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      cliScript
      pkgs.libnotify
      pkgs.alejandra
      pkgs.curl
    ];

    # Expose helpers to host-specific hostcmd.nix
    _module.args.sys = sys;
  };
}
