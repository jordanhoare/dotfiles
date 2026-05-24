# ADR 0010 — WSL repository location

## Context

ADR 0007 placed all repos at `~/repositories/` across all platforms for consistency, including WSL. This was later reconsidered when two WSL-specific constraints surfaced:

1. **Windows toolchain access** - large project repos are cross-compiled or built for Windows targets. The Windows toolchain requires native Windows filesystem paths (`D:\`). Repos on the WSL home filesystem (`~/`) are inaccessible to Windows-side build tools.

2. **Windows app interop** - VSCode, Obsidian, and Ghostty on the Windows side open repos from the Windows filesystem. Accessing `\\wsl$\...` paths is slower and unreliable for file watchers.

The git performance cost of `/mnt/d/` (slower `git status`, `git add`, branch switching due to the 9P filesystem layer) was weighed against the toolchain and interop requirements. Because the large repos are the same ones requiring Windows access, there is no clean split - the tradeoff is accepted in full.

## Decision

On WSL, all repositories including dotfiles live at `/mnt/d/repositories/`. On macOS and native Linux the canonical location remains `~/repositories/`.

The `DOTFILES` env var on WSL resolves to `/mnt/d/repositories/dotfiles`. The Makefile and all scripts use `$(dirname $0)/..` or equivalent rather than hardcoding a path, so they work correctly regardless of filesystem location.

## How Nix handles this

Home Manager creates symlinks in `~/` (WSL home, Linux filesystem) that point to their targets in `/mnt/d/repositories/dotfiles/` (Windows filesystem). For example:

```
~/.zshrc  →  /mnt/d/repositories/dotfiles/home/.zshrc
~/.config/starship/starship.toml  →  /mnt/d/repositories/dotfiles/config/starship/starship.toml
```

Symlink creation and `make switch` run entirely within WSL and work correctly against `/mnt/d/` paths. The `home.file` entries in `common.nix` use the `dotfiles` variable which resolves to the repo root regardless of filesystem location.

The one remaining cost: zsh reads several symlink targets across the 9P boundary on every shell startup (`.zshrc`, `.zshenv`, `.zprofile`, sheldon plugins). This is measurable but acceptable given the constraints above.

## Consequences

- Git operations on large repos are slower on WSL due to 9P filesystem overhead - accepted
- Shell startup reads dotfile symlink targets across the 9P boundary - accepted
- Windows toolchain, VSCode, Obsidian, and Ghostty all access repos natively without `\\wsl$\...` indirection
- Dotfiles repo survives a WSL reinstall (Windows filesystem is not wiped)
- `~/repositories/` does not exist as a directory on WSL - no convenience symlink to avoid confusion about the canonical location
- ADR 0007 is superseded
