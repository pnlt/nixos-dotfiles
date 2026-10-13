{...}: {
  networking = {
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
    networkmanager = {
      enable = true;
    };
  };

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSSEC = "false";
      DNSOverTLS = "true";
      Domains = ["~."];
      DNS = [
        "1.1.1.1#cloudflare-dns.com"
        "1.0.0.1#cloudflare-dns.com"
      ];
      FallbackDNS = [
        "8.8.8.8"
        "8.8.4.4"
      ];
    };
  };
}
