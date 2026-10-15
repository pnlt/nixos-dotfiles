{pkgs, ...}: {
  home.packages = with pkgs; [
    lua-language-server
    bash-language-server
    typescript
    clang-tools
    efm-langserver
    stylua
    luaPackages.luacheck
    ruff
    prettierd
    eslint_d
    fixjson
    shellcheck
    cpplint
    revive
    tree-sitter
  ];
}
