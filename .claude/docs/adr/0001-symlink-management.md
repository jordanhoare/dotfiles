# ADR 0001 — Symlink management via stow [SUPERSEDED by ADR 0009]

## Context

Dotfiles need to be live-editable from the repo without a copy or sync step. Config files land in multiple target directories (`$HOME`, `~/.config/`, `~/.ssh/`) and only a hand-picked subset of each directory should be tracked — not everything chromium or other apps drop into `~/.config/`.

Stow links the *contents* of a package directory into a target. A single package targeting `~/.config/` can contain multiple app subdirectories (`git/`, `starship/`, `sheldon/`) — stow links each subdirectory as a unit, leaving everything else in `~/.config/` untouched.

Files placed into a managed directory outside of stow (e.g. SSH private keys dropped into `~/.ssh/`) are never touched by stow.

## Decision

Two stow packages, each with a distinct target:

- `home/` — stow target `~` — shell files and SSH config
- `config/` — stow target `~/.config` — per-app config directories

```
stow -d ~/repositories/dotfiles -t ~        home
stow -d ~/repositories/dotfiles -t ~/.config config
```

Directories that cannot be managed by stow (Windows paths, `/etc/`, WSL-specific) live in `todo/` and are applied manually.

## Consequences

- Editing any tracked dotfile in the repo is immediately live
- Only explicitly added files are tracked — untracked files in `~/.config/` or `~/.ssh/` are left alone
- stow must be installed before symlinking (bootstrap prereq)
- `todo/` holds configs that need manual handling per-platform
