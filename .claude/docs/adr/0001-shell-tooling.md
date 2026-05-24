# ADR 0001 — Shell tooling: prompt and plugin manager

## Context

The shell prompt and plugin manager must work identically across WSL, native Linux, and macOS from a single config file each, with no per-machine setup.

## Decision

- **Starship** as the prompt - single `starship.toml`, cross-platform, git identity display configurable per profile
- **Sheldon** as the plugin manager - plugins declared in `sheldon/plugins.toml`, updated with `sheldon lock --update`

Both are installed via Nix.

## Consequences

- `sheldon lock --update` is the only command needed to update all plugins
- Git identity display in the prompt is controlled via `starship.toml`
