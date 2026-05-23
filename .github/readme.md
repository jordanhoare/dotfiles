# dotfiles

Personal dotfiles for WSL, Linux, and macOS. Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Tooling

| Tool | Purpose |
|---|---|
| zsh | Shell |
| Ghostty | Terminal |
| tmux | Multiplexer |
| Starship | Prompt |
| Sheldon | Plugin manager |
| GNU Stow | Symlink management |
| uv | Python |
| nvm | Node |

## Key features

- **Dual git identity** - `git personal` / `git private` switches identity and gh auth
- **SOPS encryption** - private git config encrypted at rest, decrypted via SSH key
- **Platform-aware shell** - WSL, Linux, and macOS each source platform-specific config

## Setup

#### Clone

```bash
git clone git@personal:jordanhoare/dotfiles.git ~/repositories/dotfiles
```

#### Stow

```bash
stow -d ~/repositories/dotfiles -t ~ home
stow -d ~/repositories/dotfiles -t ~/.config config
```

## Platforms

| Platform | Notes |
|---|---|
| WSL | Primary — dotfiles live on Windows FS at `/mnt/d/repositories/` |
| Linux | Clone to `~/repositories/dotfiles`, same stow commands |
| macOS | Clone to `~/repositories/dotfiles`, use `brew` for prereqs |

See `.claude/CLAUDE.md` for full bootstrap and key restore instructions.
