# ADR 0005 — Package management and dotfile linking

## Context

Dotfiles and tools must be reproducible across macOS, Linux, and WSL with pinned versions, a single activation command, and no per-machine debugging.

## Decision

**Nix + Home Manager + Flakes** manage all packages and dotfile symlinks.

- All CLI tools declared in nixpkgs. `flake.lock` committed, pinning every version across all machines.
- `home.file` links config files from the repo to their target paths. Files stay as raw files in `home/`, `config/`, `bin/` - not generated from Nix expressions. Edit in repo, change is immediately live.
- Three named configurations in `nix/flake.nix`: `jordan@macos`, `jordan@linux`, `jordan@wsl`.
- **nix-darwin** manages macOS system-level config. Homebrew is retained solely for Docker Desktop via `homebrew.casks` with `cleanup = "zap"` making the list authoritative. All other GUI apps are in nixpkgs.
- **winget** with `windows/winget.json` covers Windows-native apps. winutil handles one-time Windows tweaks.

## Consequences

- `flake.lock` updated deliberately via `up`
- Never run `brew install` directly - declare casks in `nix/modules/macos-system.nix`
- Adding a tool means editing the appropriate module and running `make switch`
