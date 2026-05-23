# Setup

## Prerequisites

Install `git` and `stow`:

```bash
# Debian/Ubuntu/WSL
sudo apt install git stow

# macOS
brew install git stow
```

## Clone

```bash
git clone git@personal:jordanhoare/dotfiles.git ~/repositories/dotfiles
```

## Stow

```bash
stow -d ~/repositories/dotfiles -t ~ home
stow -d ~/repositories/dotfiles -t ~/.config config
```

## SSH Keys

Restore from Bitwarden:

```bash
# Personal key
cat > ~/.ssh/personal  # paste, Ctrl+D
cat > ~/.ssh/private   # paste, Ctrl+D
chmod 600 ~/.ssh/personal ~/.ssh/private
```

## Decrypt private git config

```bash
sops --decrypt --output $DOTFILES/config/git/private $DOTFILES/config/git/private.enc
```

## Install tools

- [Starship](https://starship.rs/guide/#step-1-install-starship)
- [Sheldon](https://sheldon.cli.rs/installation.html)
- [tmux](https://github.com/tmux/tmux/wiki/Installing)
- [Ghostty](https://ghostty.org/download)
- [uv](https://docs.astral.sh/uv/getting-started/installation/)
- [nvm](https://github.com/nvm-sh/nvm#installing-and-updating)

## Verify

```bash
git whoami          # Jordan Hoare <jordanhoare0@gmail.com>
ssh -T git@personal # authenticates as jordanhoare
ssh -T git@private  # authenticates as private account
```
