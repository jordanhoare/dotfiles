# Setup

## Prerequisites

### WSL

On WSL, clone onto the Windows filesystem - the Linux home is slow for git and won't survive a WSL reinstall.

```bash
sudo apt install git stow
mkdir -p /mnt/d/repositories
cd /mnt/d/repositories
```

### Linux

```bash
sudo apt install git stow
mkdir -p ~/repositories
cd ~/repositories
```

### macOS

```bash
brew install git stow
mkdir -p ~/repositories
cd ~/repositories
```

## Clone

```bash
git clone https://github.com/jordanhoare/dotfiles.git
cd dotfiles
```

## SSH Keys

Restore from Bitwarden - see [Bitwarden SSH Key Restore](Bitwarden-SSH).

## Decrypt and stow

Install [SOPS](https://github.com/getsops/sops/releases), then:

```bash
make decrypt
make stow
```

On Linux/WSL, also stow the etc package (sets timezone and locale):

```bash
make stow-etc
```

Switch the remote to SSH now that `~/.ssh/config` is in place:

```bash
git remote set-url origin git@personal:jordanhoare/dotfiles.git
```

## Install tools

- [Starship](https://starship.rs/guide/#step-1-install-starship)
- [Sheldon](https://sheldon.cli.rs/installation.html)
- [tmux](https://github.com/tmux/tmux/wiki/Installing)
- [Ghostty](https://ghostty.org/download)
- [uv](https://docs.astral.sh/uv/getting-started/installation/)
- [Bun](https://bun.sh/docs/installation)

## Verify

```bash
make verify
git whoami          # Jordan Hoare <jordanhoare0@gmail.com>
ssh -T git@personal # authenticates as jordanhoare
ssh -T git@private  # authenticates as private account
```
