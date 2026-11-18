{...}: {
  flake.modules.homeManager.dev = {
    pkgs,
    lib,
    ...
  }: {
    home = {
      packages = with pkgs; [
        kubectl
        kubectx # kubectx + kubens
        kubernetes-helm
        stern
        kind
        opentofu
        awscli2

        buf
        grpcurl
        xh
      ];

      sessionVariables.KIND_EXPERIMENTAL_PROVIDER = "podman";

      shellAliases = {
        k = "kubectl";
        kx = "kubectx";
        kn = "kubens";
        tf = "tofu";
      };
    };

    programs.k9s = {
      enable = true;
      settings.k9s = {
        refreshRate = 2;
        ui = {
          logoless = true;
          crumbsless = true;
        };
      };
    };

    programs.zsh.completionInit = lib.mkAfter ''
      autoload -Uz bashcompinit && bashcompinit
      complete -C ${lib.getExe pkgs.opentofu} tofu
    '';
  };
}
