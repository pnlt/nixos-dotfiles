{...}: {
  flake.modules.homeManager.editors = {pkgs, ...}: {
    home.packages = [pkgs.llm-agents.orca];
  };
}
