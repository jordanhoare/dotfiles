# Setup

Dotfiles are managed via [Nix](https://nixos.org) and [Home Manager](https://github.com/nix-community/home-manager). On Windows, [winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/) handles native apps with Nix running inside WSL.

`make switch` auto-detects the platform. Override with `make switch PLATFORM=jordan@linux` if needed.

## Prerequisites

| Platform | Steps |
|---|---|
| macOS | `xcode-select --install` then install Nix: https://nixos.org/download/#nix-install-macos |
| Linux | `sudo apt install -y git curl make` then install Nix: https://nixos.org/download/#nix-install-linux |
| WSL | See [Setup - WSL](Setup-WSL) |

Open a new shell after installing Nix to pick up the environment.

## Install

```bash
mkdir -p ~/repositories
git clone https://github.com/jordanhoare/dotfiles.git ~/repositories/dotfiles
cd ~/repositories/dotfiles
make switch        # pass 1: installs bw and sops via Nix
make secrets       # restores SSH keys from Bitwarden, decrypts git identity
git remote set-url origin git@personal:jordanhoare/dotfiles.git
make switch        # pass 2: links the now-decrypted git identity
make verify
```

> Two passes are required on a fresh machine. Pass 1 installs the tools needed by `make secrets`. Pass 2 picks up the private git identity that secrets restores.

## Updating

```bash
up    # updates flake.lock, switches, and upgrades all other tools
```

## Adding tools

Edit `nix/modules/common.nix` (or the relevant platform module under `nix/modules/`) and run `make switch`. Never install tools manually - all packages go through Nix.
