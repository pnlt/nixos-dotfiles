{
  config,
  user,
  ...
}: {
  preservation = {
    enable = true;

    preserveAt."/persist" = {
      # Each entry becomes a tmpfiles rule defaulting to 0755 root:root that sorts ahead of
      # the nixpkgs rule for the same path, so restrictive modes must be pinned here.
      directories = [
        "/var/log"
        "/var/lib/systemd"
        "/var/lib/NetworkManager"
        "/var/lib/alsa"
        "/var/lib/power-profiles-daemon"
        {
          directory = "/root";
          mode = "0700";
        }
        {
          directory = "/var/lib/private";
          mode = "0700";
        }
        {
          directory = "/var/lib/sbctl";
          mode = "0700";
        }
        {
          directory = "/etc/NetworkManager/system-connections";
          mode = "0700";
        }
        {
          directory = "/var/db/sudo";
          mode = "0711";
        }
        {
          directory = "/var/lib/nixos";
          inInitrd = true;
        }
        {
          directory = "/home/${user.alias}";
          inherit (config.users.users.${user.alias}) group;
          user = user.alias;
          mode = "0700";
        }
      ];

      files = [
        {
          # sops-nix decrypts with this during activation, before systemd mounts the rest
          file = "/etc/ssh/ssh_host_ed25519_key";
          inInitrd = true;
          configureParent = true;
          mode = "0600";
        }
        {
          file = "/etc/ssh/ssh_host_ed25519_key.pub";
          mode = "0644";
        }
        {
          file = "/etc/machine-id";
          how = "symlink";
          inInitrd = true;
          configureParent = true;
        }
        "/etc/ly/save.txt"
        "/etc/kernel/entry-token"
      ];
    };
  };

  systemd.services.systemd-machine-id-commit = {
    unitConfig.ConditionPathIsMountPoint = ["" "/persist/etc/machine-id"];
    serviceConfig.ExecStart = ["" "systemd-machine-id-setup --commit --root /persist"];
  };
}
