{...}: {
  flake.modules.homeManager.agents = {
    config,
    lib,
    mkAgentKit,
    pkgs,
    ...
  }: let
    kit = mkAgentKit {};
    json = pkgs.formats.json {};
    statusLine = pkgs.writeShellScript "agy-statusline" ''
      exec ${lib.getExe pkgs.jq} -r -f ${./antigravity-statusline.jq}
    '';
    settings = json.generate "agy-settings" {
      agentMode = "accept-edits";
      altScreenMode = "always";
      notifications = true;
      pickerGrouping = "grouped";
      showFeedbackSurvey = false;
      showTips = false;
      statusLine = {
        type = "command";
        command = toString statusLine;
        enabled = true;
      };
      toolPermission = "always-proceed";
      useG1Credits = false;
    };
  in {
    home.packages = [pkgs.llm-agents.antigravity-cli];

    # agy persists model selection and workspace trust in the same file.
    home.activation.antigravitySettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [[ ! -v DRY_RUN ]]; then (
        path="$HOME/.gemini/antigravity-cli/settings.json"
        mkdir -p "''${path%/*}"
        current=/dev/null
        if [[ -e "$path" ]]; then current="$path"; fi
        temporary=$(mktemp "$path.XXXXXX")
        trap 'rm -f "$temporary"' EXIT
        ${lib.getExe pkgs.jq} -es '
          if length > 2 or any(.[]; type != "object") then error("Expected settings objects")
          else add end
        ' "$current" ${settings} > "$temporary"
        if ! cmp -s "$temporary" "$path"; then mv -T "$temporary" "$path"; fi
      ); fi
    '';

    home.file = {
      ".gemini/GEMINI.md".text = ''
        ${kit.memories}

        Devices go through `phone`, never raw adb, simctl or emulator. Each thread holds its own device; to hand one to a sub-agent, run `phone release -t <device>` first and let the sub-agent acquire it.

        ${builtins.readFile "${pkgs.rtk}/share/rtk/hooks/rtk-awareness-high.md"}
      '';

      ".gemini/config/skills.json".source = json.generate "agy-skills" {
        entries = [{path = "${config.home.homeDirectory}/.agents/skills";}];
      };

      ".gemini/config/mcp_config.json".source = json.generate "agy-mcp" {
        mcpServers = lib.mapAttrs (_: server:
          builtins.removeAttrs server ["type" "disabled_tools" "startup_timeout_sec"])
        (kit.mkMcpServers {});
      };

      ".gemini/config/hooks.json".source = json.generate "agy-hooks" {
        rtk.PreToolUse = [
          (kit.mkCmdEntry {
            matcher = "run_command";
            commands = ["${lib.getExe pkgs.rtk} hook antigravity"];
          })
        ];
        herdr.PreInvocation = [
          {
            type = "command";
            command = kit.mkHerdrSessionCmd "antigravity_cli";
            timeout = 2;
          }
        ];
      };
    };
  };
}
