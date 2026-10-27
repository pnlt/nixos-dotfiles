{
  # Claude only for now. luisquin's tree also has codex, cursor-cli, freebuff,
  # grok, opencode and pi; drop their directories in here and import them when
  # you want them (lib.nix only implements the "claude" permission target).
  imports = [
    ./claude
  ];
}
