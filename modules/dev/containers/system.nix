{...}: {
  flake.modules.nixos.containers = {
    virtualisation = {
      containers.registries.settings.unqualified-search-registries = ["docker.io"];

      podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true;
        autoPrune = {
          enable = true;
          flags = ["--all"];
        };
      };
    };
  };
}
