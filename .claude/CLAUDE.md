# Dotfiles - Claude Code Context

## What this repo is

Personal dotfiles for Jordan Hoare. Managed via Nix and Home Manager across three platforms: WSL (primary), native Linux (VMs), macOS.

## Repository structure

### Dotfile packages

| Package | Target | Contents |
|---|---|---|
| `home/` | `~` | `.zshrc`, `.zprofile`, `.zshenv`, `.zsh/`, `.ssh/config`, `.claude/`, `.codex/` |
| `config/` | `~/.config` | `git/`, `gh/`, `ghostty/`, `mise/`, `uv/`, `sheldon/`, etc. |
| `bin/` | `~/bin` | Personal executable scripts |
| `etc/` | `/etc` | `timezone`, `locale.conf` - Linux/WSL only, applied manually |

Only files declared in `nix/modules/base.nix` (or a platform module) are linked. Everything else in `~/.config/` is untouched.

### Claude skills

`home/.claude/skills/` is bucketed by lifecycle for navigation:

| Bucket | Holds |
|---|---|
| `plan/` | grill, grilling, prd, issue, wayfinder, prototype, research |
| `build/` | implement, implement-spec, tdd, deep-modules, review, pr, debug, merge-conflicts |
| `health/` | architecture, triage, setup, retro |
| `learn/` | teach, garden |
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
| `nix/modules/base.nix` | Imports the shared modules below, plus the packages and links every platform gets |
| `nix/modules/shell.nix`, `git.nix`, `dev.nix`, `cloud.nix`, `zed.nix`, `firefox.nix` | Shared modules, one per concern |
| `nix/modules/linux.nix` | Native Linux: GUI apps (Obsidian, Bitwarden, Hyprland) |
| `nix/modules/wsl.nix` | WSL: no GUI apps; those come from Windows via winget |
| `nix/modules/macos.nix` | macOS nix-darwin system config + nested home-manager user config |

### Windows

| File | Purpose |
|---|---|
| `win/winget.json` | Declarative Windows app list |
| `win/bootstrap.ps1` | Windows body of `mise run switch`: winget import plus config links (ADR 0011, 0014) |
| `win/mise.toml` | Windows global mise config, smaller than `config/mise/config.toml` |
| `win/secrets.ps1` | Restores the personal SSH key and gh login from Bitwarden |

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
mise tasks        # list every task
mise run switch   # activate the platform config (nix-darwin, Home Manager, or win/bootstrap.ps1)
mise run secrets  # restore SSH keys from Bitwarden, then decrypt every *.sops file
mise run hooks    # install the git hooks (prek)
mise run decrypt  # decrypt every *.sops file to its target under ~
mise run up       # self-update mise, update flake.lock, switch, upgrade all tools
```

Tasks live under `.mise/` and replace the Makefile (ADR 0016). `.mise/config.toml` holds one-line tasks and never an `[env]` table; anything longer is a script in `.mise/tasks/`, as a `.sh` file with a `.ps1` pair when Windows needs it. Its `[tools]` table pins only the repo's own check tools; a tool the baseline in `config/mise/config.toml` also pins takes the baseline's version.

## New machine setup

```bash
curl -fsSL https://raw.githubusercontent.com/jordanhoare/dotfiles/main/install.sh | sh   # macOS, Linux, WSL
irm https://raw.githubusercontent.com/jordanhoare/dotfiles/main/install.ps1 | iex        # Windows
mise run secrets  # restores SSH keys, decrypts git identity to ~/.config/git/private
git remote set-url origin git@personal:jordanhoare/dotfiles.git
```

The entry script installs git and mise, clones the repo, and runs `mise run bootstrap`, which installs Nix, switches, and installs the baseline runtimes. mise is the only hand-installed program; Home Manager does not install it (ADR 0016).

The private git identity is decrypted directly to `~/.config/git/private` (not into the repo), and `config/git/config` picks it up via `[includeIf]` - silently no-ops when missing, so no second `mise run switch` pass is needed.

On WSL, clone to `/mnt/d/repositories/dotfiles` not `~/repositories/`. See ADR 0006.

## Adding tools

One installer per tool (ADR 0002): if mise can install it and a project may pin it, add it to `config/mise/config.toml` or the project's `mise.toml`. Otherwise edit `nix/modules/base.nix` (or the platform module) and run `mise run switch`. Never install tools manually, and never declare one tool in both.

## SSH and secrets

Private keys are never committed - restored from Bitwarden via `mise run secrets`.

An encrypted file is a `*.sops` file in the package matching its target: `home/<path>.sops` decrypts to `~/<path>`, `config/<path>.sops` to `~/.config/<path>`. One `.sops.yaml` rule encrypts them to `~/.ssh/personal`. `mise run decrypt` writes them all, on every platform; a committed config includes each (`[includeIf]` in `config/git/config`, `Include ~/.ssh/config.d/*` in `home/.ssh/config`). Add or change one with `sops edit <path>.sops`, never by editing the decrypted copy (ADR 0017).

## What NOT to do

- Never commit plaintext git identity - `~/.config/git/private` lives outside the repo by design
- Never hardcode the private GitHub username in any public file
- Never declare a tool in both a Nix module and a mise config
- Never cite an ADR in code or config comments. The comment carries the why in its own words; ADR references live in `.claude/docs/`
- Never run `brew install` directly - declare casks in `nix/modules/macos.nix`
- Never use `/mnt/d` paths in shared zsh config - WSL-only

## Agent context

- `.claude/docs/context.md` - domain overview and scope
- `.claude/docs/glossary.md` - canonical terms
- `.claude/docs/adr/` - architectural decisions
