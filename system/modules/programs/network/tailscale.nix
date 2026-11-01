{...}: {
  services.tailscale = {
    enable = true;
    # Tailscale SSH: tailnet identity replaces sshd and keys, reachable only over the tailnet.
    extraSetFlags = ["--ssh"];
  };

  networking.networkmanager.unmanaged = ["interface-name:tailscale*"];

  preservation.preserveAt."/persist".directories = [
    {
      directory = "/var/lib/tailscale";
      mode = "0700";
    }
  ];
}
