{...}: {
  flake.modules.homeManager.go = {pkgs, ...}: {
    home.packages = with pkgs; [
      air # hot reload
      delve # debugger
      errcheck # to check not handled errors
      gcc # to link C code
      go-protobuf
      gofumpt # gofmt but better
      golangci-lint # linter
      gopls # Go language server
      govulncheck # audit dependencies
      grpc-tools
    ];
  };
}
