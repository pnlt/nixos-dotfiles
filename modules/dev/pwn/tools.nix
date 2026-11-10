{...}: {
  flake.modules.homeManager.pwn = {pkgs, ...}: {
    home.packages = with pkgs; [
      osv-scanner
      aircrack-ng
      nmap
    ];
  };
}
