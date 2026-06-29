# ADR 0010 - Editor: Zed over VSCode

## Context

The previous setup managed VSCode via `nix/modules/vscode.nix`, linking `config/Code/User/settings.json` and `keybindings.json` from the Nix store into `~/.config/Code/User/` on Linux/WSL and `Library/Application Support/Code/User/` on macOS. VSCode was also declared in `win/winget.json`. In practice the editor in daily use has shifted to Zed, which is now installed on every platform and configured under `config/zed/` per ADR 0007.

Continuing to manage VSCode in parallel kept dead config in the repo, pulled an unused package on every fresh Windows install, and left contradictory bootstrap docs (the wiki described VSCode symlinks while the in-repo README documented Zed symlinks).

## Decision

Zed is the single managed editor across WSL, native Linux, and macOS. VSCode is no longer installed or configured by the dotfiles.

- `nix/modules/vscode.nix` removed, along with its import in `base.nix`
- `config/Code/` removed
- `Microsoft.VisualStudioCode` removed from `win/winget.json`
- All editor-related Windows bootstrap instructions point at Zed

## Consequences

- One editor, one config tree (`config/zed/`), one set of bootstrap steps
- VSCode-fork tools (Windsurf, Cursor) remain available - they are installed manually per machine if needed and are out of scope for the managed dotfiles
- A future move back to VSCode or to a third editor reintroduces a module under `nix/modules/<editor>.nix` following the same pattern as `zed.nix`
- ADR 0007 still governs the immutability stance for the managed editor's config
