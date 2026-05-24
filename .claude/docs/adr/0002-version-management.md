# ADR 0002 — Runtime version management

## Context

Multiple runtime versions (Go, Python, dotnet, bun, opentofu, etc.) need to be available globally across macOS, Linux, and WSL, switchable on demand without per-repo config files.

## Decision

- **mise** manages all runtime versions globally via `~/.config/mise/config.toml`
- `mise use --global <tool>@<version>` switches versions explicitly - no per-repo `.mise.toml` files
- **uv** manages Python packages, virtualenvs, and global Python CLI tools - composes with mise-managed Python without conflict
- **bun** covers JS/TS runtimes; mise manages bun versions

## Consequences

- `mise upgrade` keeps all runtimes current
- Shell startup cost of `mise activate` is accepted
- Per-repo `.mise.toml` files should not be created in this maintainer's repos
