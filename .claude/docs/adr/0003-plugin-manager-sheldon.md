# ADR 0003 — Plugin manager via Sheldon

## Context

Replacing oh-my-zsh requires an alternative way to install and update zsh plugins. Manual git clones require manual update discipline; git submodules are painful to maintain.

## Decision

Use Sheldon as the plugin manager. Plugins declared in `sheldon/plugins.toml` managed by stow. Update with `sheldon lock --update`.

## Consequences

- Plugin updates are a single command rather than per-directory git pulls
- TOML config is version controlled and human-readable
- Sheldon binary must be installed as a bootstrap dependency
- Initial plugin set: zsh-autosuggestions, zsh-syntax-highlighting, zsh-history-substring-search, zsh-completions
