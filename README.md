<h1 align="center">dotfiles</h1>

<div align="center">

Personal dotfiles for WSL, Linux, and macOS — managed with [GNU Stow](https://www.gnu.org/software/stow/).

<div align="center">
  <a href="#setup">Setup</a>
  <span> • </span>
  <a href="#tooling">Tooling</a>
  <span> • </span>
  <a href="#features">Features</a>
  <span> • </span>
  <a href="#platforms">Platforms</a>
</div>

<p></p>

![zsh](https://img.shields.io/badge/shell-zsh-89DCEB?style=for-the-badge&logo=gnubash&logoColor=white)
![Starship](https://img.shields.io/badge/prompt-starship-DD0B78?style=for-the-badge&logo=starship&logoColor=white)
![GNU Stow](https://img.shields.io/badge/stow-dotfiles-4A90D9?style=for-the-badge&logo=gnu&logoColor=white)

</div>

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

> See `.claude/CLAUDE.md` for full bootstrap, SSH key restore, and SOPS decrypt instructions.

## Tooling

| Tool | Purpose |
|---|---|
| [zsh](https://www.zsh.org/) | Shell |
| [Ghostty](https://ghostty.org/) | Terminal |
| [tmux](https://github.com/tmux/tmux) | Multiplexer |
| [Starship](https://starship.rs/) | Prompt |
| [Sheldon](https://sheldon.cli.rs/) | Plugin manager |
| [GNU Stow](https://www.gnu.org/software/stow/) | Symlink management |
| [uv](https://github.com/astral-sh/uv) | Python |
| [nvm](https://github.com/nvm-sh/nvm) | Node |

## Features

- **Dual git identity** - `git personal` / `git private` switches identity and gh auth seamlessly
- **SOPS encryption** - private git config encrypted at rest via SSH key, never committed in plaintext
- **Platform-aware shell** - WSL, Linux, and macOS each source their own platform config
- **Starship prompt** - shows git branch, identity, cloud context (AWS, GCP, Azure), and language versions

## Platforms

| Platform | Notes |
|---|---|
| WSL | Primary - dotfiles live on Windows FS at `/mnt/d/repositories/` |
| Linux | Clone to `~/repositories/dotfiles`, same stow commands |
| macOS | Clone to `~/repositories/dotfiles`, use `brew` for prereqs |
