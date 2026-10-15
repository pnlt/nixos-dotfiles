{
  imports = [
    ./user.nix
    ./sudo.nix
    ./keyring.nix
    ./do-not-track.nix
    # ./gnupg.nix   # later if you use GPG
    # ./ssh.nix     # later — his is very personal
    # ./apparmor.nix # optional hardening
  ];
}
