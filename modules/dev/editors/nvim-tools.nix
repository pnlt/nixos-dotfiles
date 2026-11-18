{...}: {
  flake.modules.homeManager.editors = {pkgs, ...}: {
    home.packages = with pkgs; [
      lua-language-server
      stylua
      luaPackages.luacheck

      bash-language-server
      shellcheck

      typescript
      typescript-language-server
      prettierd
      eslint_d
      tailwindcss-language-server
      vtsls
      vscode-langservers-extracted

      cpplint
      clang-tools

      ruff

      fixjson

      yaml-language-server # compose, GitHub Actions, k8s schemas via SchemaStore
      dockerfile-language-server

      revive

      tree-sitter
      efm-langserver
      copilot-language-server
    ];
  };
}
