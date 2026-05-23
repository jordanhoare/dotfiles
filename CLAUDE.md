# Dotfiles — Claude Code Context

## What this repo is
Personal dotfiles for Jordan Hoare. Managed via GNU stow — editing any tracked file is immediately live via symlink. Targets three platforms: WSL (primary), native Linux (VMs), macOS.

## Repository structure

### Stow packages
Two packages, each targeting a different directory. See `docs/internal/runbooks/stow.md` for commands.

| Package | Stow target | Contents |
|---|---|---|
| `home/` | `~` | `.zshrc`, `.zlogin`, `.zprofile`, `.ssh/config` |
| `config/` | `~/.config` | `git/` — add new app dirs here as needed |

Only files explicitly placed in these packages are tracked. Everything else in `~` or `~/.config/` is untouched by stow.

### Non-stow directories

| Directory | Purpose |
|---|---|
| `docs/` | ADRs, glossary, runbooks |
| `todo/` | Configs requiring manual placement — Windows apps, WSL `/etc/` targets, platform-specific |

### zsh
`.zshrc` sets `$DOTFILES` and sources everything it needs directly via that variable. The `home/` package stows the shell entry points; the rest of the zsh config is referenced via `$DOTFILES`.

## Key tooling
See `docs/internal/adr/` for full rationale.

- **Shell:** zsh
- **Terminal:** Ghostty
- **Multiplexer:** tmux
- **Prompt:** Starship
- **Plugin manager:** Sheldon (updates via `sheldon lock --update`)
- **Symlinks:** GNU stow (two-package pattern — see ADR 0001)
- **Python:** uv
- **Node:** nvm

## SSH
`home/.ssh/config` is the only SSH file committed. Stow symlinks it to `~/.ssh/config`. Private keys are never committed — restore from Bitwarden on a new machine:

1. Bitwarden → SSH key "personal" → `cat > ~/.ssh/personal` → paste → Ctrl+D
2. Bitwarden → SSH key "private" → `cat > ~/.ssh/private` → paste → Ctrl+D
3. `chmod 600 ~/.ssh/personal ~/.ssh/private`

## SOPS
`config/git/private.enc` is encrypted for `~/.ssh/private` — decrypted automatically by bootstrap. See `docs/internal/runbooks/sops.md` for manual decrypt, re-encrypt, and debugging commands.

## New machine setup

### Windows/WSL
1. Run `todo/wsl/wsl-enable.ps1` in PowerShell as Administrator
2. Install Ubuntu from Microsoft Store, complete initial user setup

### Linux/WSL/macOS
1. Install prereqs: `sudo apt install git stow` (or brew equivalent)
2. Clone: `git clone git@personal:jordanhoare/dotfiles.git ~/repositories/dotfiles`
3. Stow: `stow -d ~/repositories/dotfiles -t ~ home && stow -d ~/repositories/dotfiles -t ~/.config config`
4. Restore SSH keys from Bitwarden (see SSH section above)
5. Decrypt private git config: see `docs/internal/runbooks/sops.md`
6. Install tools: starship, sheldon, tmux, ghostty, nvm, uv

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

### Issue tracker
Issues live in GitHub Issues (`jordanhoare/dotfiles`). See `docs/agents/issue-tracker.md`.

### Triage labels
Default canonical label strings (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs
Single-context — `docs/internal/context.md` + `docs/internal/glossary.md` + `docs/internal/adr/`. See `docs/agents/domain.md`.
