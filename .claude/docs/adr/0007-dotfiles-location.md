# ADR 0007 — Dotfiles repository location [SUPERSEDED by ADR 0010]

## Context

On WSL the repo lived at /mnt/d/repositories/dotfiles (Windows D: drive). This path doesn't exist on native Linux or macOS, causing the bootstrap to break on those platforms.

## Decision

Dotfiles repo lives at ~/repositories/dotfiles on all platforms. On WSL this means the WSL home directory (~), not the Windows drive. This gives a consistent path that works identically across WSL, Linux VMs, and macOS.

## Consequences

- DOTFILES env var resolves consistently across all platforms
- Platform detection no longer needs to set different DOTFILES paths
- Existing WSL setup at /mnt/d/repositories/dotfiles is a personal working location, not the canonical install path
