{...}: {
  flake.modules.homeManager.go = {
    config,
    pkgs,
    ...
  }: {
    programs.go = {
      enable = true;
      package = pkgs.go;

      env = {
        GOBIN = "${config.home.homeDirectory}/go/bin";
        GOPATH = "${config.home.homeDirectory}/go";
        GO111MODULE = "on";
        CGO_ENABLED = "0";
        GOTOOLCHAIN = "local";
      };
      telemetry.mode = "off";
    };
  };
}
