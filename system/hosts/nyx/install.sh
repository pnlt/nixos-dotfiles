#!/usr/bin/env bash
# Live USB, as root: repair | fresh <dir with key_host.txt, ssh_host_ed25519_key.pub, keys.txt, sbctl/>
set -euo pipefail

mode=${1:-}
secrets=${2:-}
repo=$(cd "$(dirname "$0")/../../.." && pwd)
nixf=(nix --extra-experimental-features "nix-command flakes")

[ "$(id -u)" = 0 ] || { echo "run as root"; exit 1; }

case $mode in
repair) ;;
fresh)
  for f in key_host.txt ssh_host_ed25519_key.pub keys.txt sbctl/keys; do
    [ -e "$secrets/$f" ] || { echo "missing $secrets/$f"; exit 1; }
  done
  read -rp "Wipe the whole Kingston drive (NixOS + /home)? Type WIPE: " ok
  [ "$ok" = WIPE ] || exit 1
  for m in destroy format; do
    "${nixf[@]}" run github:nix-community/disko -- --yes-wipe-all-disks --mode $m "$repo/system/hosts/nyx/disko-config.nix"
  done
  ;;
*)
  echo "usage: $0 repair | fresh <secrets-dir>"
  exit 1
  ;;
esac

mountpoint -q /mnt || mount -t tmpfs -o mode=755 none /mnt
mkdir -p /mnt/{boot,persist,nix,tmp}
mountpoint -q /mnt/persist || mount /dev/disk/by-label/nixos /mnt/persist
mountpoint -q /mnt/boot || mount -o fmask=0077,dmask=0077 /dev/disk/by-label/boot /mnt/boot
mkdir -p /mnt/persist/{nix,tmp}
mountpoint -q /mnt/nix || mount --bind /mnt/persist/nix /mnt/nix
mountpoint -q /mnt/tmp || mount --bind /mnt/persist/tmp /mnt/tmp
swapon /dev/disk/by-label/swap 2>/dev/null || true

if [ "$mode" = fresh ]; then
  for root in /mnt/persist /mnt; do
    install -d -m755 "$root/etc/ssh"
    # Drive adds a blank first line that ssh-keygen and sops reject.
    grep -v '^$' "$secrets/key_host.txt" | install -m600 /dev/stdin "$root/etc/ssh/ssh_host_ed25519_key"
    install -m644 "$secrets/ssh_host_ed25519_key.pub" "$root/etc/ssh/"
    install -d -m755 "$root/var/lib"
    cp -a "$secrets/sbctl" "$root/var/lib/sbctl"
    chmod -R go-rwx "$root/var/lib/sbctl"
  done

  home=/mnt/persist/home/pnlt
  install -d -m700 -o 1000 -g 100 "$home" "$home/.config" "$home/.config/sops" "$home/.config/sops/age"
  install -m600 -o 1000 -g 100 "$secrets/keys.txt" "$home/.config/sops/age/keys.txt"
  [ -d "$home/nixos-dotfiles" ] || { cp -a "$repo" "$home/nixos-dotfiles" && chown -R 1000:100 "$home/nixos-dotfiles"; }
fi

cores=$(awk '/MemTotal/ {c = int($2 / 1048576 / 3); print (c < 2 ? 2 : c)}' /proc/meminfo)
TMPDIR=/mnt/persist/tmp nixos-install --root /mnt --flake "$repo#nyx" --no-root-passwd --cores "$cores" --max-jobs 1

echo "done: reboot, remove the USB"
