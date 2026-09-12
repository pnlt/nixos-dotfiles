
# nixos-dotfiles

> Personal, modular **NixOS + Home Manager** configuration built around a declarative Wayland desktop.

This repository contains my personal NixOS configuration for the host **`nyx`** and user **`pnlt`**.

It uses **Nix flakes**, **Home Manager**, and a modular architecture that separates system configuration, user configuration, local packages, overlays, and reusable modules.

> [!WARNING]
> This is primarily a **personal configuration repository**, not a universal one-click NixOS installer.
> You should review and adapt the hardware configuration, disk layout, networking, usernames, secrets, and host-specific settings before using it on another machine.

---

## ✨ Overview

The configuration is designed around a minimal, modular, and declarative workflow.

### Core principles

* 🧩 Modular configuration structure
* ❄️ Fully declarative NixOS and Home Manager setup
* 🖥️ Wayland-first desktop environment
* 🪟 **Niri** as the compositor
* 🏠 Home Manager integrated as a NixOS module
* 📦 Local packages and reusable modules
* 🔄 Flake-based dependency management
* 🧹 Minimal system without unnecessary GUI configuration tools
* 🛠️ Custom `nyx` helper CLI for common system tasks

---

## 🖥️ Stack

| Layer                | Choice                                 |
| -------------------- | -------------------------------------- |
| Operating System     | NixOS                                  |
| Nixpkgs              | Unstable / `26.11` line                |
| Configuration        | Nix flakes                             |
| User Environment     | Home Manager                           |
| Compositor           | [Niri](https://github.com/YaLTeR/niri) |
| Display Protocol     | Wayland                                |
| Terminal             | Ghostty                                |
| Status Bar           | Waybar                                 |
| Optional Panels      | Eww                                    |
| Notifications        | Mako                                   |
| Wallpaper            | Awww                                   |
| Application Launcher | Fuzzel                                 |
| Secondary Launcher   | Raffi                                  |
| Browser              | Zen Browser                            |
| Shell / Helper       | Custom `nyx` CLI                       |
| Package Management   | Nix + Home Manager                     |

---

## 📁 Repository Structure

```text
.
├── flake.nix
├── flake.toml
├── flake.lock
├── LICENSE
│
├── overlays/
│   └── Nixpkgs and flake input overlays
│
├── pkgs/
│   └── Local packages, helpers, and reusable Nix modules
│
├── system/
│   ├── hosts/
│   │   └── nyx/
│   │       ├── configuration.nix
│   │       ├── hardware-configuration.nix
│   │       └── host-specific configuration
│   │
│   └── modules/
│       ├── hardware/
│       ├── desktop/
│       ├── filesystem/
│       ├── security/
│       ├── shell/
│       └── other system modules
│
├── home/
│   ├── profiles/
│   │   └── pnlt/
│   │       └── User profile entry point
│   │
│   ├── modules/
│   │   ├── desktop/
│   │   │   ├── niri/
│   │   │   ├── waybar/
│   │   │   ├── awww/
│   │   │   └── other desktop components
│   │   │
│   │   └── programs/
│   │       └── User applications and configuration
│   │
│   └── options/
│       └── Custom Home Manager options
│
└── lib/
    └── Shared metadata and helper functions
```

---

# 🧩 Architecture

The repository separates **system-level configuration** from **user-level configuration**.

```text
NixOS Host
│
├── system/
│   ├── hosts/
│   └── modules/
│
└── Home Manager
    │
    ├── home/profiles/
    ├── home/modules/
    └── home/options/
```

### System configuration

The `system/` directory is responsible for machine-level configuration such as:

* Bootloader
* Kernel and hardware
* Filesystems
* Networking
* Security
* System services
* Desktop/session infrastructure
* Host-specific configuration

### Home Manager configuration

The `home/` directory manages the user environment:

* Niri
* Waybar
* Ghostty
* Fuzzel
* Raffi
* Mako
* Awww
* Shell configuration
* User applications
* Desktop behavior

This separation keeps system configuration independent from user-specific preferences.

---

# 🚀 Features

## 🪟 Niri Desktop

The primary desktop environment is built around **Niri**, a scrollable-tiling Wayland compositor.

The configuration includes declarative management for:

* Window behavior
* Keybindings
* Startup applications
* Workspace behavior
* Window rules
* Desktop appearance

The complete configuration can be found in:

```text
home/modules/desktop/niri/
```

---

## 🖥️ Waybar

Waybar provides the primary status bar.

Depending on the enabled modules, it can display information such as:

* Workspaces
* Active window
* CPU usage
* Memory usage
* Network status
* Audio
* Battery
* Clock
* System controls

Configuration lives under:

```text
home/modules/desktop/waybar/
```

---

## 🖼️ Wallpaper Management

Wallpaper handling is managed declaratively with **Awww**.

Useful keybinding:

| Keybinding        | Action                       |
| ----------------- | ---------------------------- |
| `Mod + Shift + W` | Switch to the next wallpaper |

> [!NOTE]
> Large wallpaper collections can increase Nix evaluation and store copy costs. Keep the wallpaper directory reasonably sized.

---

## 🔍 Application Launchers

Two launchers are configured:

| Launcher | Keybinding    |
| -------- | ------------- |
| Fuzzel   | `Mod + D`     |
| Raffi    | `Mod + Space` |

---

## 💻 Ghostty Terminal

The terminal environment uses **Ghostty**.

This configuration integrates Ghostty through a local flake named:

```text
nyx-terminal
```

The input can either be:

* A local path
* A Git repository
* Your own remote fork

Review the Ghostty input in `flake.nix` when moving the configuration to another machine.

---

## 🌐 Browser

The configuration includes **Zen Browser** through a flake-based setup.

Browser configuration is kept declarative where possible.

---

# ⚡ Quick Start

## Apply the current configuration

From the repository root:

```bash
cd ~/nixos-dotfiles
sudo nixos-rebuild switch --flake .#nyx
```

Or from anywhere:

```bash
sudo nixos-rebuild switch --flake ~/nixos-dotfiles#nyx
```

---

# 🛠️ `nyx` Helper CLI

The repository provides a custom helper command named:

```bash
nyx
```

Common commands include:

```bash
nyx update
```

Apply the current configuration.

```bash
nyx clean
```

Run cleanup / garbage collection tasks if configured.

```bash
nyx help
```

Display available commands.

The exact functionality depends on the host helper implementation.

---

# 📦 Requirements

Before using this configuration, you should have:

* NixOS installed
* Nix flakes enabled
* `nix-command` enabled
* Git installed
* Basic familiarity with NixOS configuration
* A compatible host configuration

The flake exposes the host:

```text
.#nyx
```

The default configuration assumes:

```text
Host: nyx
User: pnlt
```

These values should be changed if you are adapting the repository for another machine.

---

# 🧊 Enable Flakes

Make sure experimental features are enabled.

For example:

```nix
nix.settings.experimental-features = [
  "nix-command"
  "flakes"
];
```

You can verify flakes are available with:

```bash
nix flake --help
```

---

# 💾 Fresh Installation

The following steps describe how to adapt this repository for a new machine or a complete reinstall.

> [!IMPORTANT]
> Do not blindly copy the existing hardware configuration to another machine.

---

## 1. Install NixOS

Install a minimal NixOS system.

After installation, ensure that:

* Networking works
* Git is available
* Flakes are enabled
* The target disk layout is configured correctly

---

## 2. Clone the repository

```bash
git clone https://github.com/YOUR_USER/nixos-dotfiles.git ~/nixos-dotfiles

cd ~/nixos-dotfiles
```

Replace:

```text
YOUR_USER
```

with your GitHub username.

---

## 3. Generate the hardware configuration

Generate a hardware configuration for the current machine:

```bash
sudo nixos-generate-config \
  --show-hardware-config \
  > system/hosts/nyx/hardware-configuration.nix
```

Then carefully review:

* Filesystems
* Disk UUIDs
* Bootloader configuration
* CPU configuration
* GPU configuration
* Kernel modules
* Networking

> [!WARNING]
> Hardware configuration is machine-specific. Never assume another machine's disk UUIDs, filesystems, or boot configuration are correct for your system.

---

## 4. Review host metadata

Update configuration metadata if necessary.

Check files such as:

```text
flake.toml
flake.nix
system/hosts/
home/profiles/
```

You may need to change:

* Hostname
* Username
* Home directory
* Flake output name

For example:

```text
nyx → your-hostname
pnlt → your-username
```

---

## 5. Configure `nyx-terminal`

Ghostty depends on the `nyx-terminal` flake input.

If it is configured as a local path, either:

1. Clone it to the expected location, or
2. Change the input to point to your own Git repository.

For example:

```text
github:YOUR_USER/nyx-terminal
```

Review the input definition in:

```text
flake.nix
```

---

## 6. Review secrets and machine-specific configuration

Before building, check for:

* SSH keys
* API keys
* Tokens
* Age keys
* SOPS configuration
* Private repositories
* Host-specific paths

Do **not** commit sensitive information.

Recommended approaches include:

* `sops-nix`
* `agenix`
* Environment-based secrets where appropriate

---

## 7. Build and switch

From the repository root:

```bash
sudo nixos-rebuild switch --flake .#nyx
```

If successful, the new configuration will become active.

---

## 8. Reboot

After the first successful build:

```bash
sudo reboot
```

Then start your configured Wayland session.

Depending on your setup, this may be handled through:

* `greetd`
* Another display manager
* Automatic session startup

---

# ⌨️ Useful Keybindings

Some common Niri keybindings:

| Keybinding        | Action               |
| ----------------- | -------------------- |
| `Mod + Return`    | Open Ghostty         |
| `Mod + D`         | Open Fuzzel          |
| `Mod + Space`     | Open Raffi           |
| `Mod + Shift + W` | Next wallpaper       |
| `Mod + Q`         | Close focused window |

For the complete keybinding list, see:

```text
home/modules/desktop/niri/
```

---

# 🔄 Updating the System

After modifying the configuration:

```bash
cd ~/nixos-dotfiles
```

Then rebuild:

```bash
sudo nixos-rebuild switch --flake .#nyx
```

Or use:

```bash
nyx update
```

---

# 🔍 Testing Changes

For a safer workflow, you can build the configuration before switching:

```bash
sudo nixos-rebuild build --flake .#nyx
```

If the build succeeds, switch to the configuration:

```bash
sudo nixos-rebuild switch --flake .#nyx
```

For a temporary configuration test:

```bash
sudo nixos-rebuild test --flake .#nyx
```

This activates the configuration without making it the default boot configuration.

---

# ♻️ Garbage Collection

Over time, Nix can accumulate old store paths and system generations.

Depending on your configured `nyx` helper:

```bash
nyx clean
```

You can also manage generations manually.

List generations:

```bash
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

Garbage collection:

```bash
sudo nix-collect-garbage
```

Remove old system generations and collect garbage:

```bash
sudo nix-collect-garbage -d
```

> [!WARNING]
> Review your cleanup workflow before deleting generations. Old generations can be useful for rollback.

---

# ⏪ Rollback

One of the advantages of NixOS is the ability to roll back to previous system generations.

You can select an older generation from the bootloader.

You can also roll back the active profile using:

```bash
sudo nixos-rebuild switch --rollback
```

Always keep at least a few known-good generations while experimenting with major system changes.

---

# 🧠 Development Philosophy

This repository intentionally prefers:

### Declarative configuration

Configuration should live in Nix modules rather than manual system changes.

### Modular structure

Instead of placing everything inside one massive:

```text
configuration.nix
```

features are organized into smaller reusable modules.

### Minimalism

Avoid unnecessary background services, GUI configuration utilities, and configuration bloat.

### Reproducibility

A machine should be reconstructable from:

* The repository
* The flake lock file
* Required secrets
* Machine-specific hardware configuration

---

# 📌 Important Notes

## `system.stateVersion`

The `system.stateVersion` is intentionally pinned.

Updating NixOS or changing the nixpkgs channel does **not** mean you should automatically update:

```nix
system.stateVersion
```

Treat it as a compatibility setting, not a version number that should always match your current NixOS release.

---

## Home Manager state version

The same general principle applies to Home Manager's:

```nix
home.stateVersion
```

Do not change it casually.

---

## Secrets

Never commit sensitive files such as:

```text
SSH private keys
API tokens
Passwords
age private keys
Raw SOPS material
Private certificates
```

Use a proper secret management solution for sensitive configuration.

---

## Wallpaper Collections

Large wallpaper directories can increase:

* Evaluation time
* Copy time
* Nix store usage

Keep wallpaper collections reasonably sized, especially when they are included directly in the flake.

---

# 🧹 GitHub Language Statistics

The repository may use `.gitattributes` rules similar to:

```gitattributes
pkgs/** linguist-vendored
pkgs/**/*.nix -linguist-vendored
```

This tells GitHub Linguist:

* Treat most files under `pkgs/` as vendored/generated content
* Still count `.nix` files as part of the repository's actual source code

This helps keep GitHub's language statistics representative of the configuration itself.

---

# 📚 Useful Commands

### Rebuild

```bash
sudo nixos-rebuild switch --flake .#nyx
```

### Test without making it the default boot configuration

```bash
sudo nixos-rebuild test --flake .#nyx
```

### Build only

```bash
sudo nixos-rebuild build --flake .#nyx
```

### Update flake inputs

```bash
nix flake update
```

### Check the flake

```bash
nix flake check
```

### Show flake outputs

```bash
nix flake show
```

### Garbage collect

```bash
sudo nix-collect-garbage -d
```

---

# 📄 License

This project is licensed under the **MIT License**.

See [LICENSE](LICENSE) for details.

---

# 🙋 About

This is a personal NixOS configuration maintained primarily for my own machines and workflow.

Feel free to explore the structure, reuse ideas, and adapt parts of the configuration for your own setup.

However, expect machine-specific assumptions and personal preferences throughout the repository.

> **Read the configuration before running it. Never blindly deploy another person's NixOS configuration to your own machine.**
