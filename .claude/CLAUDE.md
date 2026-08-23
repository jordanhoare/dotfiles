# Dotfiles - Claude Code Context

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

Only files declared in `nix/modules/base.nix` (or a platform module) are linked. Everything else in `~/.config/` is untouched.

### Claude skills

`home/.claude/skills/` is bucketed by lifecycle for navigation:

| Bucket | Holds |
|---|---|
| `plan/` | grill, grilling, prd, issue, wayfinder, prototype, research |
| `build/` | implement, tdd, deep-modules, review, debug, merge-conflicts |
| `health/` | architecture, triage, setup |
| `lang/` | uv, ruff, ty, dotnet, nix, mkdocs |
| `meta/` | ask, commits, domain, technical-writing, wait-what, wizard, writing-for-agents |

Claude Code only globs `skills/*/SKILL.md`, one level deep, so `base.nix` reads the
bucket tree and links every skill **flat** into `~/.claude/skills`. The buckets never
reach the harness. Adding a skill, or a whole new bucket, needs no Nix change.

### Nix modules

| File | Purpose |
|---|---|
| `nix/flake.nix` | Entry point - defines `darwinConfigurations.macos`, `homeConfigurations.linux`, `homeConfigurations.wsl` |
| `nix/flake.lock` | Committed - pins all package versions |
| `nix/modules/base.nix` | Packages and dotfile links shared across all platforms |
| `nix/modules/linux.nix` | Native Linux: shared Linux bits plus GUI apps (Obsidian, Bitwarden) |
| `nix/modules/wsl.nix` | WSL: shared Linux bits only; GUI apps come from Windows via winget |
| `nix/modules/macos.nix` | macOS nix-darwin system config + nested home-manager user config |

### Windows

| File | Purpose |
|---|---|
| `win/winget.json` | Declarative Windows app list |
| `win/README.md` | Windows bootstrap steps |

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
make secrets      # restore SSH keys from Bitwarden, decrypt git identity to ~/.config/git/private
make hooks        # install pre-commit hooks
make decrypt      # decrypt SOPS-encrypted git identity to ~/.config/git/private
up                # update flake.lock + switch + upgrade all tools
```

## New machine setup

```bash
make switch       # installs bw, sops, and all tooling via Nix
make secrets      # restores SSH keys, decrypts git identity to ~/.config/git/private
git remote set-url origin git@personal:jordanhoare/dotfiles.git
```

The private git identity is decrypted directly to `~/.config/git/private` (not into the repo), and `config/git/config` picks it up via `[includeIf]` - silently no-ops when missing, so no second `make switch` pass is needed.

On WSL, clone to `/mnt/d/repositories/dotfiles` not `~/repositories/`. See ADR 0006.

## Adding tools

Edit `nix/modules/base.nix` (or the appropriate platform module) and run `make switch`. Never install tools manually.

## SSH and secrets

`home/.ssh/config` is the only SSH file committed. Private keys are never committed - restored from Bitwarden via `make secrets`. `config/git/private.enc` is SOPS-encrypted against `~/.ssh/personal`.

## What NOT to do

- Never commit plaintext git identity - `~/.config/git/private` lives outside the repo by design
- Never hardcode the private GitHub username in any public file
- Never run `brew install` directly - declare casks in `nix/modules/macos.nix`
- Never use `/mnt/d` paths in shared zsh config - WSL-only

## Agent context

- `.claude/docs/context.md` - domain overview and scope
- `.claude/docs/glossary.md` - canonical terms
- `.claude/docs/adr/` - architectural decisions
