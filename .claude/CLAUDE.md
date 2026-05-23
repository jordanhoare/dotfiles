# Dotfiles — Claude Code Context

## What this repo is

Personal dotfiles for Jordan Hoare. Managed via GNU stow — editing any tracked file is immediately live via symlink. Targets three platforms: WSL (primary), native Linux (VMs), macOS.

## Repository structure

### Stow packages

Four packages, each targeting a different directory.

| Package | Stow target | Stow command | Contents |
|---|---|---|---|
| `home/` | `~` | `stow -t ~ home` | `.zshrc`, `.zlogin`, `.zprofile`, `.zshenv`, `.ssh/config` |
| `config/` | `~/.config` | `stow -t ~/.config config` | `git/`, `ghostty/`, `uv/`, `sheldon/`, etc. |
| `bin/` | `~/bin` | `stow -t ~/bin bin` | Personal executable scripts |
| `etc/` | `/etc` | `sudo stow -t /etc etc` | `timezone`, `locale.conf` - Linux/WSL only |

Only files explicitly placed in these packages are tracked. Everything else is untouched by stow.

### Non-stow directories

| Directory | Purpose |
|---|---|
| `.claude/docs/` | ADRs, glossary, context, agent instructions |
| `.github/wiki/` | Wiki pages synced to GitHub Wiki on push |

### zsh

`.zshrc` sets `$DOTFILES` and sources everything it needs directly via that variable. The `home/` package stows the shell entry points; the rest of the zsh config is referenced via `$DOTFILES`.

## Key tooling

See `.claude/docs/adr/` for full rationale.

- **Shell:** zsh
- **Terminal:** Ghostty
- **Multiplexer:** tmux
- **Prompt:** Starship
- **Plugin manager:** Sheldon (updates via `sheldon lock --update`)
- **Symlinks:** GNU stow (four-package pattern — see ADR 0001)
- **Python:** uv
- **Node/JS:** Bun

## SSH

`home/.ssh/config` is the only SSH file committed. Stow symlinks it to `~/.ssh/config`. Private keys are never committed — restore from Bitwarden on a new machine:

1. Bitwarden → SSH key "personal" → `cat > ~/.ssh/personal` → paste → Ctrl+D
2. Bitwarden → SSH key "private" → `cat > ~/.ssh/private` → paste → Ctrl+D
3. `chmod 600 ~/.ssh/personal ~/.ssh/private`

## SOPS

`config/git/private.enc` is encrypted against `~/.ssh/personal`. See `config/git/README.md` for decrypt and re-encrypt commands.

## New machine setup

### Windows/WSL

1. Run `todo/wsl/wsl-enable.ps1` in PowerShell as Administrator
2. Install Ubuntu from Microsoft Store, complete initial user setup

### Linux/WSL/macOS

1. Install prereqs: `sudo apt install git stow` (or brew equivalent)
2. Clone: `git clone git@personal:jordanhoare/dotfiles.git ~/repositories/dotfiles`
3. Stow: `make stow` (symlinks all four packages; sudo prompt expected for etc/)
4. Restore SSH keys from Bitwarden (see SSH section above)
5. Decrypt private git config: see `config/git/README.md`
6. Install tools: starship, sheldon, tmux, ghostty, uv, bun

### Verify

```bash
git whoami              # Jordan Hoare <jordanhoare0@gmail.com>
ssh -T git@personal     # authenticates as jordanhoare
ssh -T git@private      # authenticates as private account
```

## What NOT to do

- Never commit `config/git/private` — gitignored plaintext secrets
- Never hardcode the private GitHub username in any public file — lives only in `config/git/private` (gitignored, symlinked to `~/.config/git/private` via stow)
- Never add `eval "$(mise activate zsh)"` — mise was removed (see ADR 0004)
- Never use `/mnt/d` paths in shared zsh config — WSL-only

## Agent skills

### Domain docs

Single-context — `.claude/docs/context.md` + `.claude/docs/glossary.md` + `.claude/docs/adr/`.
