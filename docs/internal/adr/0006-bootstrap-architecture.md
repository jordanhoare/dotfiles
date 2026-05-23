# ADR 0006 — Bootstrap architecture

## Context
The existing bootstrap.sh is a single monolithic script with ordering bugs, undefined functions, and duplicate steps. It is not idempotent and cannot be safely re-run. It also has no strategy for the Windows/WSL chicken-and-egg problem.

## Decision
Staged bootstrap with the following structure:

```
bootstrap/
  install.sh          # entry point: curl | bash, detects platform, runs stages
  stages/
    00-prereqs.sh     # package manager, git, curl, stow, zsh
    01-clone.sh       # clone dotfiles to ~/repositories/dotfiles
    02-stow.sh        # symlink all dotfiles via stow
    03-tools.sh       # starship, sheldon, tmux, ghostty
    04-secrets.sh     # SSH key restore prompt + sops decrypt
    05-ecosystem.sh   # nvm, pyenv, uv
  platform/
    wsl.sh
    linux.sh
    macos.sh
  windows/
    wsl-enable.ps1    # PowerShell: enable WSL before any Linux shell exists
```

All stage scripts are written in bash (lowest common denominator — guaranteed before zsh is installed). Each stage is idempotent: safe to re-run and always converges to the same end state.

## Consequences
- Dotfiles repo lives at ~/repositories/dotfiles on all platforms
- WSL has a separate PowerShell pre-step before install.sh can run
- Failed bootstrap can be resumed by re-running install.sh — completed stages no-op
- Old bootstrap.sh, shell/functions/, and shell/scripts/ are removed
