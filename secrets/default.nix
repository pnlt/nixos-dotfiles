{
  pkgs,
  user,
  ...
}: {
  sops = {
    defaultSopsFile = ./secrets.yaml;
    # openssh is off, so sops-nix cannot derive this from services.openssh.hostKeys.
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

    secrets."users/${user.alias}-password-hash".neededForUsers = true;
  };

  environment.systemPackages = [pkgs.sops];
}
