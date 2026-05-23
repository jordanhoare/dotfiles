# ADR 0001 — Symlink management via stow

## Context
Dotfiles need to be live-editable from the repo without a copy or sync step. The repo previously had both stow-based symlinking and direct path referencing in conflict.

## Decision
Use GNU stow exclusively to manage symlinks from `$HOME` into the dotfiles repo. Direct path referencing is removed.

## Consequences
- Editing any dotfile in the repo is immediately live — no bootstrap step needed after initial setup
- stow must be installed as a bootstrap dependency before symlinking
- Broken symlinks are the failure mode to watch for (stow handles conflicts with `--adopt`)
