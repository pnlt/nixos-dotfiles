{...}: {
  flake.modules.nixos.core = {
    systemd.services."user@".serviceConfig.Delegate = "cpu cpuset io memory pids";
  };
}
