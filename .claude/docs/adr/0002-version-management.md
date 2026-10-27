# ADR 0002 - Runtime version management

Amended 2026-10-27. The first version of this ADR allowed only the global config and forbade per-repo `mise.toml` files. That rule is withdrawn.

## Context

Runtimes (Go, Python, node, bun, dotnet, rust) and project CLIs must be available on macOS, Linux, WSL and native Windows. Two repos must be able to run different node versions without either one editing a global list.

The "global config only" rule produced two faults. Tools that one repo needed were pinned for every machine. No rule said which installer owned a tool, so `sops` was installed by both Home Manager and mise, and PATH order decided which copy ran in a given shell.

## Decision

- **mise** manages runtimes and every tool a project could pin, on all four platforms.
- `config/mise/config.toml`, linked to `~/.config/mise/config.toml`, is the **baseline**: the runtimes and daily CLIs wanted in every shell. `win/mise.toml` is the Windows baseline.
- A repo's own `mise.toml` pins the tools that repo needs. mise resolves each tool from the nearest config, so a repo pin outranks the baseline for that tool. Repo pins are the normal case.
- **One installer per tool.** If mise can install a tool and a project may pin it, mise owns it and no Nix module declares it. Nix owns tools no project pins, such as `jq` and `ripgrep`. ADR 0016 applies the same rule to mise itself.
- **Shell wiring** follows the mise docs: `mise activate zsh --shims` in `.zprofile` for login shells (SSH, editor remote servers), `mise activate zsh` in `.zshrc` for interactive shells. `.zshenv` does not touch mise. Scripts call `mise exec` or `mise run`.
- **uv** manages Python packages, virtualenvs and global Python CLI tools, on top of the mise-managed Python.
- **bun** covers JS/TS; mise manages bun versions.

## Consequences

- `mise use -g <tool>@<version>` edits `config/mise/config.toml` in the repo, so `git status` shows the change.
- The baseline list should shrink to runtimes and daily CLIs. Infrastructure pins (kubectl, helm, terraform, vault) move to the repos that use them as those repos are touched.
- A tool added to the global mise config before Bootstrap is backed up with the pre-existing config file and stops being read.
- A non-login, non-interactive shell such as `ssh host <command>` reads only `.zshenv`, so it does not see mise tools. Prefix such commands with `mise exec --`.
- Shell startup cost of `mise activate` is accepted.
