{
  config,
  pkgs,
  lib,
  inputs,
  system,
  ...
}: let
  encore = inputs.encore.packages.${system}.encore;
in {
  home.packages = [pkgs.codebase-memory-mcp];

  programs.techdebt.enable = true;

  # One shared process per server (or per workspace), multiplexed to every
  # agent session by pkgs/mcp-gateway. The gateway module also registers each
  # entry in programs.mcp.servers, which claude picks up through
  # enableMcpIntegration + kit.mkMcpServers.
  services.mcp-gateway = {
    enable = true;
    servers = [
      {
        name = "techdebt-mcp";
        package = config.programs.techdebt.package;
        args = ["mcp"];
        scope = "workspace";
      }
      {
        name = "encore";
        package = encore;
        command = lib.getExe' encore "encore";
        args = ["mcp" "run"];
        scope = "workspace";
        requires.anyFileExists = ["encore.app"];
        disabledTools = [
          "query_database"
          "get_secrets"
        ];
      }
      {
        name = "codebase-memory-mcp";
        package = pkgs.codebase-memory-mcp;
        scope = "workspace";
      }
      {
        name = "chrome-devtools";
        package = pkgs.chrome-devtools-mcp;
        args = [
          "--executablePath"
          (lib.getExe config.programs.chromium.package)
          "--headless"
          "--isolated"
        ];
        reapWhenIdle = true;
      }
      # Not ported: davinci-resolve (needs DaVinci Resolve) and
      # firefox-devtools (needs his marionette-enabled browser profile).
    ];
  };

  programs.mcp = {
    enable = true;
    servers = {
      context7.url = "https://mcp.context7.com/mcp";
      # linear.url = "https://mcp.linear.app/mcp"; # only if you use Linear
    };
  };
}
