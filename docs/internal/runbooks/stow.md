# Stow Runbook

GNU Stow symlinks the *contents* of a package directory into a target. Two packages, two targets:

- `home/` → `~` — shell files, SSH config
- `config/` → `~/.config` — per-app config directories

Stow only manages what it created. Files dropped into `~/.ssh/`, `~/.config/`, or `~` outside of stow are never touched.

All commands run from any directory — `-d` specifies the dotfiles root.

## Apply all packages

```bash
stow -d ~/repositories/dotfiles -t ~ home
stow -d ~/repositories/dotfiles -t ~/.config config
```

## Unstow

```bash
stow -d ~/repositories/dotfiles -t ~ -D home
stow -d ~/repositories/dotfiles -t ~/.config -D config
```

## Simulate before applying

```bash
stow -d ~/repositories/dotfiles -t ~ --simulate home
stow -d ~/repositories/dotfiles -t ~/.config --simulate config
```

## Adding a new app to config/

Create its directory under `config/` in the repo, then re-stow:

```bash
mkdir -p ~/repositories/dotfiles/config/starship
cp ~/.config/starship/starship.toml ~/repositories/dotfiles/config/starship/
stow -d ~/repositories/dotfiles -t ~/.config config
```

## Conflicts

If stow reports a conflict, a real file is blocking the symlink. Back it up and remove it first:

```bash
mv ~/.config/starship/starship.toml ~/.config/starship/starship.toml.bak
stow -d ~/repositories/dotfiles -t ~/.config config
```
