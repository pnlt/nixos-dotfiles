{...}: {
  flake.modules.homeManager.agents = {
    pkgs,
    lib,
    ...
  }: let
    snippets = pkgs.writeText "agent-say-snippets" ''
      continue
      commit it
      try again
      what's the status?
      what are you doing right now and why?
      review it again with a subagent
      amend instead of adding a commit
      use subagents
    '';

    agent-say = pkgs.writeShellApplication {
      name = "agent-say";
      runtimeInputs = [pkgs.winnow pkgs.jq pkgs.herdr pkgs.tmux];
      runtimeEnv.AGENT_SAY_SNIPPETS = snippets;
      text = builtins.readFile ./agent-say.sh;
    };
  in {
    home.packages = [agent-say];

    programs.herdr.settings.keys.command = [
      {
        key = "prefix+i";
        type = "popup";
        width = "60%";
        height = "40%";
        command = lib.getExe agent-say;
        description = "send a common instruction to the focused agent";
      }
    ];

    programs.tmux.extraConfig = ''
      bind-key i display-popup -E -w 60% -h 40% ${lib.getExe agent-say}
    '';
  };
}
