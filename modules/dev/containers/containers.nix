{...}: {
  flake.modules.homeManager.dev = {pkgs, ...}: {
    home = {
      packages = with pkgs; [
        docker-compose # `podman compose` delegates to it
        dive
        hadolint
      ];

      sessionVariables = {
        DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/podman/podman.sock";
        # testcontainers mounts the socket into its reaper container
        TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE = "$XDG_RUNTIME_DIR/podman/podman.sock";
        TESTCONTAINERS_RYUK_DISABLED = "true";
      };

      shellAliases = {
        lzd = "lazydocker";
        dps = "docker ps -a";
        dl = "docker logs -f";
      };
    };

    programs.lazydocker = {
      enable = true;
      settings = {
        gui = {
          returnImmediately = true;
          wrapMainPanel = true;
        };
        logs = {
          timestamps = false;
          since = "60m";
        };
      };
    };
  };
}
