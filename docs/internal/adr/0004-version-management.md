# ADR 0004 — Runtime version management

## Context
The dotfiles had mise, pyenv, and nvm all present with overlapping responsibilities. Mise can replace all of them but projects across multiple orgs don't use .mise.toml, making automatic switching useless.

## Decision
- nvm for Node/TypeScript version management
- uv for Python version installation, package management, and virtual environments
- mise removed — adds startup cost with no practical benefit given project landscape
- pyenv removed — uv subsumes it entirely (`uv python install`, `uv python pin`)

## Consequences
- Two focused tools instead of one meta-tool
- No automatic version switching — manual `nvm use` / `uv python pin` as needed
- Collaborators across orgs will recognise these tools without needing to learn mise
- Shell startup is faster without pyenv and mise evals
- uv is the single source of truth for all Python concerns
