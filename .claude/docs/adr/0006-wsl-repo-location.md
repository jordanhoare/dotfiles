# ADR 0006 — WSL repository location

## Context

On WSL, repos can live either on the WSL home filesystem (`~/`) or the Windows filesystem (`/mnt/d/`). The two constraints that drive this decision:

1. **Windows toolchain access** - project repos are cross-compiled or built for Windows targets. The Windows toolchain requires native `D:\` paths; repos on the WSL home filesystem are inaccessible to Windows-side build tools.
2. **Windows app interop** - VSCode, Obsidian, and Ghostty open files from the Windows filesystem. The `\\wsl$\...` network path is slower and unreliable for file watchers.

The repos that are large enough to feel git slowness on `/mnt/d/` are the same repos requiring Windows access - no clean split exists.

## Decision

On WSL, all repositories including dotfiles live at `/mnt/d/repositories/`. On macOS and native Linux the canonical location is `~/repositories/`.

Home Manager creates symlinks in `~/` pointing across the 9P boundary into `/mnt/d/repositories/dotfiles/`. `make switch` runs entirely within WSL and works correctly against `/mnt/d/` paths.

## Consequences

- Git operations are slower on WSL due to 9P filesystem overhead - accepted
- Shell startup reads dotfile symlink targets across the 9P boundary - accepted
- Windows toolchain, VSCode, Obsidian, and Ghostty access repos natively
- Dotfiles repo survives a WSL reinstall
- `~/repositories/` does not exist as a directory on WSL
