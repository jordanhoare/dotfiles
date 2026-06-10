# Linux

## 1. Prerequisites

```bash
sudo apt install -y git curl make
```

Install Nix: https://nixos.org/download/#nix-install-linux

Open a new shell to pick up the Nix environment.

## 2. Clone

```bash
mkdir -p ~/repositories
git clone https://github.com/jordanhoare/dotfiles.git ~/repositories/dotfiles
cd ~/repositories/dotfiles
```

## 3. Activate

Installs every package, links every config file, and applies the dotfiles to your home directory.

```bash
make switch
```

## 4. Restore secrets

Logs in to Bitwarden, restores both SSH keys, and decrypts the private git profile to `~/.config/git/private`.

```bash
make secrets
```

## 5. Swap remote to SSH

```bash
git remote set-url origin git@personal:jordanhoare/dotfiles.git
```

Done. See [Home](Home) for updating, identity switching, and other daily ops.
