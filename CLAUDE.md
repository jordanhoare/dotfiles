# Dotfiles — Claude Code Context

## What this repo is
Personal dotfiles for Jordan Hoare. Managed via GNU stow — editing any file in this repo is immediately live via symlink. Targets three platforms: WSL (primary), native Linux (VMs), macOS.

## Repository structure

### Stow packages
Each of these top-level directories is a stow package. Running `stow <package>` symlinks its contents into `$HOME`.

| Package | Symlinks to |
|---|---|
| `zsh/` | `~/.zshrc`, sources `zsh/conf.d/` and `zsh/platform/` directly |
| `gitconfig/` | `~/.gitconfig` |
| `tmux/` | `~/.tmux.conf` |
| `starship/` | `~/.config/starship.toml` |
| `sheldon/` | `~/.config/sheldon/plugins.toml` |
| `ghostty/` | `~/.config/ghostty/config` |
| `ssh/` | `~/.ssh/config` |

### Non-stow directories
These are NOT stow packages. Listed in `.stow-local-ignore`.

| Directory | Purpose |
|---|---|
| `bootstrap/` | Staged idempotent install scripts |
| `docs/` | Documentation and ADRs |
| `brew/` | macOS Brewfile |
| `wsl/` | WSL-specific configs copied by bootstrap (not stowed — target is `/etc/` and Windows paths) |
| `vscode/` | VSCode settings copied by bootstrap (Windows AppData path, not stowable from WSL) |

### zsh structure
```
zsh/
  .zshrc          # loader only — detects platform, sources conf.d/ and platform/
  conf.d/         # loaded on all platforms, alphabetical order
    env.zsh       # LANG, EDITOR, BROWSER, core exports
    path.zsh      # all PATH manipulation
    aliases.zsh   # git and user aliases
    plugins.zsh   # sheldon init
    prompt.zsh    # starship init
    tools.zsh     # nvm, uv
    git.zsh       # git identity rprompt / prompt hook
  platform/       # one file sourced based on detected platform
    wsl.zsh       # WSL-specific: MSBuild, VSCode shim, /mnt paths
    linux.zsh     # native Linux specifics
    macos.zsh     # brew, mac-specific paths
```

## Key tooling decisions
See `docs/internal/adr/` for full rationale. Summary:

- **Terminal:** Ghostty
- **Multiplexer:** tmux
- **Shell:** zsh
- **Plugin manager:** Sheldon (updates via `sheldon lock --update`)
- **Prompt:** Starship (`starship.toml`)
- **Symlinks:** GNU stow
- **Version management:** nvm (Node), uv (Python — versions, packages, and virtualenvs)
- **Bootstrap:** Staged bash scripts in `bootstrap/stages/` — idempotent, re-runnable

## Git identity / profiles
Two profiles — never expose the private profile in public files:

- **personal:** `jordanhoare` — default, set in `gitconfig/.gitconfig` `[user]`
- **private:** anon identity — stored encrypted in `gitconfig/private.gitconfig.enc`, decrypted to `~/.gitconfig-private` by bootstrap stage `04-secrets.sh`

Switching:
- `git personal` — switch to jordanhoare + gh auth switch
- `git private` — switch to anon profile (reads from `~/.gitconfig-private`)
- Auto-switches in `~/repositories/private/` via `includeIf` in `.gitconfig`

SSH:
- `~/.ssh/personal` — jordanhoare key (Bitwarden: "personal"), Host alias `personal`
- `~/.ssh/private` — anon key (Bitwarden: "private"), Host alias `private`
- Clone syntax: `git clone git@personal:jordanhoare/repo.git` / `git clone git@private:<user>/repo.git`

SOPS:
- Encrypted with `~/.ssh/personal` public key
- Decrypt: `sops-personal --decrypt --input-type ini --output-type ini gitconfig/private.gitconfig.enc > ~/.gitconfig-private`
- `sops-personal` alias defined in `zsh/conf.d/aliases.zsh`

## Bootstrap
Entry point: `curl -sSL https://raw.githubusercontent.com/jordanhoare/dotfiles/main/bootstrap/install.sh | bash`

Stages run in order, each idempotent:
- `00-prereqs.sh` — package manager, git, curl, stow, zsh
- `01-clone.sh` — clone to `~/repositories/dotfiles`
- `02-stow.sh` — symlink all stow packages
- `03-tools.sh` — starship, sheldon, tmux, ghostty
- `04-secrets.sh` — prompt to restore SSH keys from Bitwarden, set permissions, then sops decrypt
- `05-ecosystem.sh` — nvm, uv

Windows/WSL pre-step: run `bootstrap/windows/wsl-enable.ps1` in PowerShell as Administrator before anything else.

## Platform detection
`.zshrc` uses `$WSL_DISTRO_NAME` (not `/mnt/d` existence) to detect WSL. Never hardcode drive paths in shared config — put them in `zsh/platform/wsl.zsh`.

## SSH
`ssh/.ssh/config` is the only file committed in the `ssh/` stow package. Stow symlinks it to `~/.ssh/config` — host aliases stay consistent across all machines automatically.

Stow is safe here because it only processes files that exist in the package. Private keys are gitignored and never present in `ssh/.ssh/`, so stow never touches them.

Everything else in `~/.ssh/` is ignored by `.gitignore` via `ssh/.ssh/*` with `!ssh/.ssh/config` as the only exception. Public keys are not committed — they live in Bitwarden alongside private keys.

Private keys are **never committed**. Restore flow on a new machine (handled by `04-secrets.sh`):
1. Open Bitwarden → SSH key item "personal" → copy private key
2. `cat > ~/.ssh/personal` → paste → Ctrl+D
3. Open Bitwarden → SSH key item "private" → copy private key
4. `cat > ~/.ssh/private` → paste → Ctrl+D
5. `chmod 600 ~/.ssh/personal ~/.ssh/private`

## New machine setup — full sequence

### Windows/WSL
1. Run `bootstrap/windows/wsl-enable.ps1` in PowerShell as Administrator
2. Install Ubuntu from Microsoft Store, complete initial user setup
3. Continue from step 2 of the Linux/WSL section below

### Linux/WSL/macOS
1. Open Bitwarden — have it ready, you'll need it in step 5
2. `curl -sSL https://raw.githubusercontent.com/jordanhoare/dotfiles/main/bootstrap/install.sh | bash`
3. Bootstrap runs stages 00–03 automatically (prereqs, clone, stow, tools)
4. Stage `04-secrets.sh` pauses and prompts:
   - Restore SSH key "personal" from Bitwarden → `~/.ssh/personal`
   - Restore SSH key "private" from Bitwarden → `~/.ssh/private`
   - Script sets `chmod 600` and runs sops decrypt → `~/.gitconfig-private`
5. Stage `05-ecosystem.sh` installs nvm and uv
6. Restart shell — prompt, plugins, and git identity are live

### After setup — verify everything works
```bash
git whoami                  # should show jordanhoare
ssh -T git@personal         # should authenticate as jordanhoare
ssh -T git@private          # should authenticate as private account
cd ~/repositories/private   # git whoami should auto-switch to private identity
```

### Working with the private git profile day-to-day
- Inside `~/repositories/private/` — identity switches automatically via `includeIf`
- On other machines or non-standard paths — run `git private` to switch manually
- To switch back — run `git personal`
- To re-decrypt private gitconfig after a key rotation or new machine:
  ```bash
  sops-personal --decrypt --input-type ini --output-type ini \
    ~/repositories/dotfiles/gitconfig/private.gitconfig.enc > ~/.gitconfig-private
  ```
- To re-encrypt after editing `private.gitconfig`:
  ```bash
  SOPS_CONFIG=/dev/null sops --encrypt --input-type ini --output-type ini \
    --age "$(cat ~/.ssh/personal.pub)" \
    ~/repositories/dotfiles/gitconfig/private.gitconfig \
    > ~/repositories/dotfiles/gitconfig/private.gitconfig.enc
  ```

## What NOT to do
- Never commit `gitconfig/private.gitconfig` — it is gitignored plaintext secrets
- Never hardcode the private GitHub username anywhere in public files — it must only exist in `~/.gitconfig-private` (decrypted from the encrypted enc file)
- Never add `eval "$(mise activate zsh)"` — mise was removed (see ADR 0004)
- Never use `/mnt/d` paths in shared zsh config — WSL-only, belongs in `platform/wsl.zsh`
- Never run `git use-main` or `git use-poe` at shell startup — identity is set by `includeIf`
