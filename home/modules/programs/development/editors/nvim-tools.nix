{pkgs, ...}: {
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

    revive

    tree-sitter
    efm-langserver
    copilot-language-server
  ];
}
