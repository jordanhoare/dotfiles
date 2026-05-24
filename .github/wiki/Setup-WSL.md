# Setup - WSL

WSL is a Linux environment running inside Windows. Nix and Home Manager manage the WSL-side tools and dotfiles exactly as they would on native Linux. Windows-native apps (VSCode, Obsidian, Bitwarden, Ghostty) are installed separately via [winget](Windows).

## How Ghostty fits in

Ghostty runs as a Windows-native app but launches your WSL zsh session directly. Everything you see in the terminal - starship, tmux, nvim - runs inside WSL and reads config from the dotfiles repo on the Windows filesystem. There is no separate Windows shell config to maintain.

## Prerequisites

Complete the Windows-side setup first: [Windows bootstrap](Windows).

Then inside WSL:

```bash
sudo apt install -y git curl make
```

Install Nix: https://nixos.org/download/#nix-install-linux

Open a new shell to pick up the Nix environment.

## Clone

The repo lives on the Windows filesystem so that Windows apps (VSCode, Obsidian) can open it natively, and it survives a WSL reinstall.

```bash
mkdir -p /mnt/d/repositories
git clone https://github.com/jordanhoare/dotfiles.git /mnt/d/repositories/dotfiles
cd /mnt/d/repositories/dotfiles
```

## Install

```bash
make switch        # pass 1: installs bw and sops via Nix
make secrets       # restores SSH keys from Bitwarden, decrypts git identity
git remote set-url origin git@personal:jordanhoare/dotfiles.git
make switch        # pass 2: links the now-decrypted git identity
make verify
```

## Windows symlinks

Ghostty and VSCode on the Windows side read config from `%APPDATA%`. Symlink them to the repo so changes stay in sync:

- [Ghostty](Windows-Ghostty)
- [VSCode](Windows-VSCode)
