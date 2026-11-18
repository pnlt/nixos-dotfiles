{...}: {
  flake.modules.homeManager.dev = {pkgs, ...}: {
    home.packages = with pkgs; [
      postgresql_18
      pgcli
      valkey # valkey-cli, wire-compatible with redis
      sqlite
      lazysql
      atlas
      sqlc
    ];
  };
}
