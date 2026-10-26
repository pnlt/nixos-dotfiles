{pkgs, ...}: {
  home.packages = with pkgs; [
    lua-language-server
    stylua
    luaPackages.luacheck

    bash-language-server
    shellcheck

    typescript
    prettierd
    eslint_d
    tailwindcss-language-server
    vtsls
    cpplint

    clang-tools

    ruff

    fixjson

    revive

    tree-sitter
    efm-langserver
  ];
}
