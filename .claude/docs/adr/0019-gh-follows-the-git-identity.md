# ADR 0019 - gh follows the git identity on every shell

## Context

Git picks the Profile by path through `[includeIf]`. `gh` has no path rule: its active account is one global value, changed by `gh auth switch`. A `gh` function in `home/.zshrc` switches the account to `git config github.user` before each call. Claude Code snapshots the user's shell functions into its Bash tool, so the same function covers agents on WSL, Linux, and macOS.

Native Windows had no equivalent. Claude Code runs Bash there through Git Bash, and Windows Terminal runs PowerShell.

## Decision

- `win/bashrc` carries the same `gh` function for Git Bash, linked to `~/.bashrc` by `win/apply.ps1`. Claude Code's Git Bash shells pick it up through the same snapshot.
- `win/profile.ps1` carries a matching `gh` function for interactive PowerShell.
- Projects assume the identity is correct and never verify or switch the `gh` account themselves.

## Consequences

- Every `gh` call costs one `git config` read and one `gh auth switch`, a local file write with no network call.
- A PreToolUse hook was considered and rejected: the shell function already reaches agent shells, so a hook would duplicate it.
- The zsh, bash, and PowerShell functions each hold the private path list. A new private path is added in each, alongside its `[includeIf]` line.
