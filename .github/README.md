<div align="center">

# nixos-dotfiles

Flake-based NixOS and Home Manager configuration for `nyx`.

[![NixOS unstable](https://img.shields.io/badge/NixOS-unstable-blue.svg?style=flat&logo=nixos&logoColor=dee1e6&colorA=101419&colorB=70a5eb)](https://github.com/NixOS/nixpkgs/tree/nixos-unstable)
[![Flakes](https://img.shields.io/badge/flakes-enabled-blue.svg?style=flat&logo=snowflake&logoColor=dee1e6&colorA=101419&colorB=70a5eb)](https://wiki.nixos.org/wiki/Flakes)
[![CI](https://github.com/pnlt/nixos-dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/pnlt/nixos-dotfiles/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg?style=flat&colorA=101419&colorB=70a5eb)](./LICENSE)

</div>

<a href="https://github.com/user-attachments/assets/c77cc56e-e198-4824-b13f-f5d0bc2a6ba4"><img src="./assets/demo.avif" alt="nyx desktop demo" width="100%"></a>

## Highlights

- **Ephemeral root** - `/` is a tmpfs wiped on every boot; state that matters is declared and kept on `/persist` through [preservation](https://github.com/nix-community/preservation).
- **Secrets** - encrypted in-repo with [sops-nix](https://github.com/Mic92/sops-nix) and age, decrypted at activation with the host key. The login password hash lives here.
- **Secure Boot** - signed UKIs via [lanzaboote](https://github.com/nix-community/lanzaboote).
- **Signed commits** - GPG agent with pinentry; Git and Jujutsu sign by default.
- **Wayland desktop** - niri, Waybar, eww, mako and vicinae, with in-house helpers for the bar and notifications.
- **Own packages** - small tools written for this setup, exposed as flake packages.
- **Upstream patches** - changes to upstream software live as intent-named `.patch` files under `overlays/patches/<pkg>`, not wrappers or forks.

## Stack

| Role            | Choice                                   |
| --------------- | ---------------------------------------- |
| Compositor      | niri                                     |
| Bar / widgets   | Waybar, eww                              |
| Notifications   | mako + hark                              |
| Launcher        | vicinae                                  |
| Login           | ly                                       |
| Terminal        | Ghostty                                  |
| Multiplexer     | herdr                                    |
| Shell / prompt  | zsh, starship                            |
| Browser         | Zen                                      |
| VCS             | Git, Jujutsu                             |
| Boot            | systemd-boot + lanzaboote, systemd initrd |

## Layout

```
.
├── flake.nix            inputs and outputs
├── flake.toml           user and host metadata
├── system/              NixOS
│   ├── hosts/nyx/       host config, hardware, nyx CLI
│   └── modules/         boot, core, desktop, fs, hardware, input, programs
├── home/                Home Manager (standalone)
│   ├── modules/         desktop, hardware, programs
│   ├── options/         custom HM options
│   └── profiles/        per-user entry point
├── config/              raw dotfiles linked by HM (niri, ghostty, nvim)
├── pkgs/                own packages, NixOS and HM modules
├── overlays/            nixpkgs overlays and patches
├── secrets/             sops-encrypted secrets
└── lib/                 helpers and metadata loader
```

## Packages

| Package          | Description                                              |
| ---------------- | -------------------------------------------------------- |
| `barfeed`        | Native status helpers for Waybar                         |
| `hark`           | Notification centre over mako's history                  |
| `heft`           | Disk usage analysis: where the space went, what changed  |
| `herdr-autoname` | Automatic tab names for herdr                            |
| `herdr-recall`   | Restores what each herdr pane was running after restart  |
| `mcp-gateway`    | Shared MCP server process gateway                        |
| `redact-secrets` | Runs a command with secrets masked in its output         |

```sh
nix run github:pnlt/nixos-dotfiles#heft
```

## Usage

This is a personal configuration tied to one machine: disk UUIDs, the persist layout and the sops recipients will not match yours. Read it, borrow from it, but do not switch to it as is.

```sh
sudo nixos-rebuild switch --flake .#nyx
home-manager switch --flake .#pnlt
```

The `nyx` helper wraps the common tasks:

```sh
nyx update system   # rebuild NixOS
nyx update home     # switch Home Manager
nyx clean           # collect garbage, prune docker and build dirs
nyx style           # format with alejandra
```

## Credits

Built on ideas and code from [luisnquin/nixos-config](https://github.com/luisnquin/nixos-config). Shared terminal modules come from [pnlt/nyx-terminal](https://github.com/pnlt/nyx-terminal).

## License

[MIT](./LICENSE)
