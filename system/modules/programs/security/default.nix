{
  imports = [
    ./user.nix
    ./sudo.nix
    ./keyring.nix
    ./do-not-track.nix
    ./gnupg.nix
    # ./ssh.nix     # later — his is very personal
    # ./apparmor.nix # optional hardening
  ];
}
