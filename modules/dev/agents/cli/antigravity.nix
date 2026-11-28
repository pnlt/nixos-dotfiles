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
    mcpServers = kit.mkMcpServers {};
    statusLine = pkgs.writeShellScript "agy-statusline" ''
      exec ${lib.getExe pkgs.jq} -r -f ${./antigravity-statusline.jq}
    '';
    titleLine = pkgs.writeShellScript "agy-title" ''
      exec ${lib.getExe pkgs.jq} -r -f ${./antigravity-title.jq}
    '';
    settings = json.generate "agy-settings" {
      agentMode = "auto";
      altScreenMode = "always";
      notifications = true;
      permissions = {
        allow =
          map (name: "mcp(${name}/*)") (builtins.attrNames mcpServers)
          ++ map (domain: "read_url(${domain})") kit.allowedDomains;
        deny = [
          "command(rm -rf /)"
          "command(regex:mkfs.*)"
          "command(pkill)"
          "command(killall)"
          "command(herdr server stop)"
          "command(tmux kill-server)"
          "command(cargo publish)"
          "command(npm publish)"
          "command(encore secret delete)"
          "command(npx prisma migrate reset)"
          "read_file(${config.home.homeDirectory}/.ssh)"
          "read_file(${config.home.homeDirectory}/nixos-dotfiles/secrets/secrets.yaml)"
        ];
      };
      pickerGrouping = "grouped";
      runningLightSpeed = "fast";
      showFeedbackSurvey = false;
      showTips = false;
      statusLine = {
        type = "command";
        command = toString statusLine;
        enabled = true;
      };
      title = {
        type = "command";
        command = toString titleLine;
        enabled = true;
      };
      toolPermission = "request-review";
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

      ".gemini/config/mcp_config.json".source = json.generate "agy-mcp" {
        mcpServers = lib.mapAttrs (_: server:
          builtins.removeAttrs server ["type" "disabled_tools" "startup_timeout_sec"])
        mcpServers;
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
