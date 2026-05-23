# Dotfiles — Claude Code Context

## What this repo is

Personal dotfiles for Jordan Hoare. Managed via Nix and Home Manager — editing any tracked file is immediately live via symlink. Targets three platforms: WSL (primary), native Linux (VMs), macOS.

## Repository structure

### Dotfile packages

Four directories whose contents are linked into place by Home Manager `home.file`.

| Package | Target | Contents |
|---|---|---|
| `home/` | `~` | `.zshrc`, `.zlogin`, `.zprofile`, `.zshenv`, `.ssh/config` |
| `config/` | `~/.config` | `git/`, `gh/`, `ghostty/`, `mise/`, `uv/`, `sheldon/`, etc. |
| `bin/` | `~/bin` | Personal executable scripts |
| `etc/` | `/etc` | `timezone`, `locale.conf` - Linux/WSL only, applied manually |

Only files explicitly declared in `nix/modules/common.nix` (or a platform module) are linked. Everything else in `~/.config/` is untouched.

### Nix modules

| File | Purpose |
|---|---|
| `nix/flake.nix` | Entry point — defines `jordan@macos`, `jordan@linux`, `jordan@wsl` |
| `nix/flake.lock` | Committed — pins all package versions |
| `nix/modules/common.nix` | Packages and dotfile links shared across all platforms |
| `nix/modules/linux-base.nix` | Shared between Linux and WSL |
| `nix/modules/macos.nix` | macOS Home Manager config |
| `nix/modules/macos-system.nix` | nix-darwin system config (Homebrew cask for Docker Desktop) |
| `nix/modules/linux.nix` | Native Linux specifics |
| `nix/modules/wsl.nix` | WSL specifics |

### Windows

| File | Purpose |
|---|---|
| `windows/winget.json` | Declarative Windows app list — import with `winget import` |
| `windows/README.md` | Full Windows bootstrap steps (winutil, winget, WSL, Nix) |

### Non-managed directories

| Directory | Purpose |
|---|---|
| `.claude/docs/` | ADRs, glossary, context, agent instructions |
| `.github/wiki/` | Wiki pages synced to GitHub Wiki on push |

### zsh

`.zshrc` sets `$DOTFILES` and sources everything it needs directly via that variable. The `home/` package provides the shell entry points; the rest of the zsh config is referenced via `$DOTFILES`.

## Key tooling

See `.claude/docs/adr/` for full rationale.

- **Shell:** zsh
- **Terminal:** Ghostty
- **Multiplexer:** tmux
- **Prompt:** Starship
- **Plugin manager:** Sheldon (updates via `sheldon lock --update`)
- **Package manager:** Nix + Home Manager (see ADR 0009)
- **Python:** uv
- **Node/JS:** Bun

## Adding tools

Edit `nix/modules/common.nix` (or the appropriate platform module) and run `make switch`. Never install tools manually with `brew install`, `apt install`, or similar.

## SSH

`home/.ssh/config` is the only SSH file committed. Home Manager links it to `~/.ssh/config`. Private keys are never committed — restore from Bitwarden on a new machine:

1. Bitwarden → SSH key "personal" → `cat > ~/.ssh/personal` → paste → Ctrl+D
2. Bitwarden → SSH key "private" → `cat > ~/.ssh/private` → paste → Ctrl+D
3. `chmod 600 ~/.ssh/personal ~/.ssh/private`

## SOPS

`config/git/private.enc` is encrypted against `~/.ssh/personal`. See `config/git/README.md` for decrypt and re-encrypt commands.

## New machine setup

See `.github/wiki/Setup.md` for full per-platform bootstrap steps.

Quick reference:

```bash
# macOS
make switch-macos

# Linux
make switch-linux

# WSL
make switch-wsl

# Verify
make verify
```

## What NOT to do

- Never commit `config/git/private` — gitignored plaintext secrets
- Never hardcode the private GitHub username in any public file — lives only in `config/git/private` (gitignored, linked to `~/.config/git/private` via Home Manager)
- Never run `brew install` directly — Homebrew is managed by nix-darwin; declare casks in `nix/modules/macos-system.nix`
- Never add `eval "$(mise activate zsh)"` — mise was removed (see ADR 0004)
- Never use `/mnt/d` paths in shared zsh config — WSL-only

## Pre-commit

Hooks are installed via `make hooks`. Run `pre-commit run --all-files` to check all files manually. Hooks enforce: trailing whitespace, EOF newlines, no private keys, YAML/TOML validity, markdownlint, and secret detection.

## Agent context

`.claude/docs/context.md` - domain overview and scope
`.claude/docs/glossary.md` - canonical terms; use these, do not drift to synonyms
`.claude/docs/adr/` - architectural decisions explaining why the tooling and layout are the way they are
