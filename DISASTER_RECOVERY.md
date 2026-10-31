# Disaster recovery (nyx)

Self-contained: paste this whole file into an AI chat when the PC is down.

## The machine

- Board: Gigabyte B650M GAMING PLUS WIFI (BIOS F41a). CPU: Ryzen 5 7500F (12 threads).
- RAM: Teamgroup DDR5-6000 16GB, SK Hynix, CL38-38-38-78 1.25V. Adding a second
  Teamgroup DDR5-6000 16GB, Micron, CL38-46-46-84 1.35V.
- Disks (`nvme0`/`nvme1` names swap between boots; always use labels or by-id):
  - Kingston SNV2S 500G (`/dev/disk/by-id/nvme-KINGSTON_SNV2S500G_50026B76868A14B9`): NixOS.
    `p1` vfat label `boot` (1G), `p2` label `swap` (4G, unused: swap is zram), `p3` ext4 label `nixos`.
  - Kioxia Exceria Plus G3 1T: Windows. Never touch it.
- NixOS flake: <https://github.com/pnlt/nixos-dotfiles> (public), host `nyx`, user `pnlt`.
- `/` is tmpfs (wiped every boot). Only `/persist` (the `nixos` partition) survives;
  `/nix`, `/tmp`, `/home/pnlt`, `/etc/ssh` host key, `/var/lib/sbctl` are bound from it.
- Secure Boot is on: lanzaboote signs the boot images with own keys in
  `/var/lib/sbctl`, enrolled in firmware together with Microsoft's.
- Secrets: sops-nix, decrypted with the host SSH key (`&nyx`) or the user age key (`&pnlt`).

## Backups (Google Drive `SECRET/`)

| File | What | Restores to |
| --- | --- | --- |
| `keys.txt` | sops age key (`&pnlt`) | `~/.config/sops/age/keys.txt` |
| `key_host.txt` + `ssh_host_ed25519_key.pub` | host key (`&nyx`) | `/etc/ssh/ssh_host_ed25519_key{,.pub}` |
| `sbctl/` | Secure Boot keys | `/var/lib/sbctl` |
| `gpg-backup/` | commit signing key | `gpg --import` |

`key_host.txt` has a blank first line from Drive; strip it (`grep -v '^$'`) before use.

## 0. Before touching hardware

BIOS (Del at boot) → Save & Exit → **Save Profiles** → pick a slot (or "Save to
File" on a USB). After any CMOS clear: Save & Exit → **Load Profiles**.
Profiles do not hold Secure Boot keys; those come back via section 3.

## 1. New RAM stick

1. Power off, unplug the PSU. Two sticks go in A2 + B2 (the board manual marks them).
2. First boot trains memory: black screen 1-3 minutes. Do not power off.
3. Enable EXPO. Mixed kits must run the looser kit: 38-46-46-84 @ 1.35V.
4. Run memtest86+ for one full pass (on the NixOS live USB boot menu).

"Memory Context Restore" and "Power Down Enable" can stay disabled. Memory
Context Restore off means full training every boot (slower boot, most stable
with mixed kits); Power Down off only costs idle power. Neither blocks a new
stick. If you enable Memory Context Restore, enable Power Down Enable too.

| Symptom | Fix |
| --- | --- |
| No POST after 5 min | Clear CMOS (jumper/button), boot without EXPO (4800). Still dead: run on the old stick alone. |
| Random crashes, `nix build` hash mismatches, memtest errors | Lower to 5600 or JEDEC, or loosen timings. Errors on the new stick alone: return it. |
| "Secure Boot violation" after a CMOS clear | Section 3. |
| Boots straight to Windows | Boot order reset: put "Linux Boot Manager" on the Kingston first. |

RAM is not part of the NixOS config; nothing needs a rebuild.

## 2. A rebuild broke boot

Choose an older generation in the boot menu (10 are kept), fix the config, then
`sudo nixos-rebuild switch --flake ~/nixos-dotfiles#nyx`.

All generations broken but `/persist` fine: boot the live USB (section 4, step
1), then

```shell
nix-shell -p git
git clone https://github.com/pnlt/nixos-dotfiles && cd nixos-dotfiles
sudo ./system/hosts/nyx/install.sh repair
```

## 3. Secure Boot violation

BIOS → Boot → Secure Boot: Disabled. Boot NixOS. Then BIOS → Secure Boot →
Secure Boot Mode: Custom → **Reset to Setup Mode**, boot NixOS, and

```shell
sudo sbctl enroll-keys -m   # -m keeps Microsoft keys so Windows still boots
```

BIOS → Secure Boot: Enabled. `sudo sbctl status` should show "Secure Boot: Enabled".

## 4. Fresh install (Kingston dead, replaced, or `/persist` lost)

Wipes the Kingston drive only. Windows stays.

1. BIOS → Secure Boot: **Disabled** (the NixOS ISO is not signed). Plug the USB,
   press **F12** at boot, pick the USB.
2. In the live session: connect Wi-Fi, Firefox → Drive → download `SECRET/` to `~/SECRET`.
3. Run:

   ```shell
   nix-shell -p git
   git clone https://github.com/pnlt/nixos-dotfiles && cd nixos-dotfiles
   sudo ./system/hosts/nyx/install.sh fresh ~/SECRET
   ```

   Type `WIPE` when asked. Codex compiles from source (30-60 min); cores scale
   with RAM so it does not run out of memory.
4. Reboot, remove the USB. BIOS → Secure Boot: **Enabled**. Your keys are back in
   `/var/lib/sbctl` and still enrolled, so it boots.
5. After login:

   ```shell
   gpg --import ~/SECRET/gpg-backup/secret-key.asc
   gpg --import-ownertrust ~/SECRET/gpg-backup/ownertrust.txt
   codex login; claude   # re-login agents
   ```

Only what is pushed to GitHub comes back. `/home` files outside the repo do not.

## Known errors

- `failed to open '/nix/store/*-source'` during rebuild: `sudo nix-store --repair --verify --check-contents`.
- Build killed, `EXIT=137`, OOM in `journalctl -k`: too many parallel rustc jobs.
  Rebuild with `--cores 4 --max-jobs 1`.
- sops "no key could decrypt": host key missing at `/persist/etc/ssh/ssh_host_ed25519_key`
  or the user key at `~/.config/sops/age/keys.txt`; restore from `SECRET/`.
