{pkgs, ...}: {
  imports = [
    ./zapret.nix
    ./dns.nix
    ./tailscale.nix
  ];

  networking.interfaces."enp8s0".wakeOnLan.enable = true;

  # quic-go/wireguard want larger UDP buffers than the kernel defaults
  boot.kernel.sysctl = {
    "net.core.rmem_default" = 262144;
    "net.core.wmem_default" = 262144;
    "net.core.rmem_max" = 7500000;
    "net.core.wmem_max" = 7500000;
    "net.ipv4.udp_rmem_min" = 16384;
    "net.ipv4.udp_wmem_min" = 16384;
  };

  systemd.services.NetworkManager-wait-online.enable = false;

  environment.systemPackages = with pkgs; [
    nload
    netcat
  ];
}
