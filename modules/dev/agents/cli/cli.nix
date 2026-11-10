{...}: {
  flake.modules.homeManager.agents = {
    # luisquin's tree also has cursor-cli, freebuff and grok; drop their
    # directories in here and import them when you want them.
  };
}
