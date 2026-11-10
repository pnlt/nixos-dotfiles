{lib, ...}: {
  options.meta = lib.mkOption {
    type = lib.types.raw;
    readOnly = true;
    description = "User, host and nix metadata from flake.toml.";
  };

  # Off nixpkgs.lib so overlays can use lib without recursing through pkgs
  config.meta =
    (import ../../lib/metadata.nix {inherit lib;})
    .mkMetadata ../../flake.toml "pnlt@nyx";
}
