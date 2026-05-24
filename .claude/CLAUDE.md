# Dotfiles — Claude Code Context

## What this repo is

Personal dotfiles for Jordan Hoare. Managed via Nix and Home Manager across three platforms: WSL (primary), native Linux (VMs), macOS.

## Repository structure

### Dotfile packages

| Package | Target | Contents |
|---|---|---|
| `home/` | `~` | `.zshrc`, `.zlogin`, `.zprofile`, `.zshenv`, `.ssh/config` |
| `config/` | `~/.config` | `git/`, `gh/`, `ghostty/`, `mise/`, `uv/`, `sheldon/`, etc. |
| `bin/` | `~/bin` | Personal executable scripts |
| `etc/` | `/etc` | `timezone`, `locale.conf` - Linux/WSL only, applied manually |

Only files declared in `nix/modules/common.nix` (or a platform module) are linked. Everything else in `~/.config/` is untouched.

### Nix modules

| File | Purpose |
|---|---|
| `nix/flake.nix` | Entry point - defines `jordan@macos`, `jordan@linux`, `jordan@wsl` |
| `nix/flake.lock` | Committed - pins all package versions |
| `nix/modules/common.nix` | Packages and dotfile links shared across all platforms |
| `nix/modules/linux-base.nix` | Shared between Linux and WSL |
| `nix/modules/macos.nix` | macOS Home Manager config |
| `nix/modules/macos-system.nix` | nix-darwin system config (Homebrew cask for Docker Desktop) |
| `nix/modules/linux.nix` | Native Linux specifics |
| `nix/modules/wsl.nix` | WSL specifics |

### Windows

| File | Purpose |
|---|---|
| `windows/winget.json` | Declarative Windows app list |
| `windows/README.md` | Windows bootstrap steps |

### Non-managed directories

| Directory | Purpose |
|---|---|
| `.claude/docs/` | ADRs, glossary, context, agent instructions |
| `.github/wiki/` | Wiki pages synced to GitHub Wiki on push |

## Key tooling

| Tool | Role | ADR |
|---|---|---|
| Nix + Home Manager | Package management and dotfile linking | 0005 |
| nix-darwin | macOS system config + Homebrew shim | 0005 |
| winget | Windows-native app management | 0005 |
| Starship | Shell prompt | 0001 |
| Sheldon | Zsh plugin manager | 0001 |
| Ghostty + tmux | Terminal and multiplexer | 0003 |
| mise | Runtime version management | 0002 |
| uv | Python packages and virtualenvs | 0002 |

## Common operations

```bash
make switch       # activate Nix config for detected platform
make secrets      # restore SSH keys from Bitwarden, decrypt git identity
make verify       # check symlinks, tools, and git identity
make hooks        # install pre-commit hooks
make decrypt      # decrypt SOPS-encrypted git identity only
up                # update flake.lock + switch + upgrade all tools
```

## New machine setup

```bash
make switch       # pass 1: installs bw and sops via Nix
make secrets      # restores SSH keys, decrypts git identity
git remote set-url origin git@personal:jordanhoare/dotfiles.git
make switch       # pass 2: links the decrypted git identity
make verify
```

On WSL, clone to `/mnt/d/repositories/dotfiles` not `~/repositories/`. See ADR 0006.

## Adding tools

Edit `nix/modules/common.nix` (or the appropriate platform module) and run `make switch`. Never install tools manually.

## SSH and secrets

`home/.ssh/config` is the only SSH file committed. Private keys are never committed - restored from Bitwarden via `make secrets`. `config/git/private.enc` is SOPS-encrypted against `~/.ssh/personal`.

## What NOT to do

- Never commit `config/git/private` - gitignored plaintext secrets
- Never hardcode the private GitHub username in any public file
- Never run `brew install` directly - declare casks in `nix/modules/macos-system.nix`
- Never use `/mnt/d` paths in shared zsh config - WSL-only

## Agent context

- `.claude/docs/context.md` - domain overview and scope
- `.claude/docs/glossary.md` - canonical terms
- `.claude/docs/adr/` - architectural decisions
