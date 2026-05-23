# ADR 0004 — Runtime version management

## Context

The dotfiles originally had mise, pyenv, and nvm with overlapping responsibilities. The first revision removed mise on the grounds that per-project auto-switching was useless since most collaborating repos don't carry `.mise.toml`. That conclusion was too narrow — it conflated auto-switching with global version management, which are separate concerns.

The real requirement is: multiple versions of runtimes (Go, Python, dotnet, bun, opentofu, etc.) available globally across macOS, Linux, and WSL, switchable on demand without per-repo config files.

## Decision

- **mise** manages all runtime versions globally — Go, Python, dotnet, bun, opentofu, and any future runtimes
- `eval "$(mise activate zsh)"` is present in `.zshrc` to wire mise-managed runtimes onto `$PATH`
- `mise use --global <tool>@<version>` is the switching mechanism — explicit, on demand, no per-repo files
- No `.mise.toml` is added to individual repositories — global config only via `~/.config/mise/config.toml`
- **uv** is retained for Python package management and virtualenvs — it composes with mise-managed Python runtimes without conflict
- **uv tool install** is the mechanism for global Python CLI tools (e.g. pre-commit)
- **nvm removed** — bun covers JS/TS runtimes; mise manages bun versions
- **pyenv removed** — mise manages Python versions; uv manages everything below the runtime

## Consequences

- Single tool for all runtime version concerns across all three platforms
- `mise upgrade` keeps all runtimes current; `mise use --global` switches versions instantly
- Shell startup cost of `mise activate` is accepted — the cross-platform consistency is worth it
- uv remains the authority for virtualenvs and Python packages; mise and uv compose cleanly
- Per-repo `.mise.toml` files are never required and should not be created in this maintainer's repos
