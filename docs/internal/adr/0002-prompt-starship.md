# ADR 0002 — Prompt via Starship

## Context
The existing prompt (w00fz-bureau-fast) is an oh-my-zsh theme and goes away when oh-my-zsh is removed. A replacement is needed that works across WSL, native Linux, and macOS.

## Decision
Use Starship as the shell prompt. Configured via a single `starship.toml` managed by stow.

## Consequences
- Single config file works identically across all platforms
- oh-my-zsh theme and the custom RPROMPT git identity hook are both replaced by Starship config
- Starship binary must be installed as a bootstrap dependency
- Git identity display (jordanhoare vs private profile) moves into starship.toml
