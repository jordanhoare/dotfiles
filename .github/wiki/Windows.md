# Windows

Windows-native apps are managed declaratively via [winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/) and activated through `win/bootstrap.ps1`. The app list lives at `win/winget.json`; the Windows-side symlink design is described in [ADR 0011](https://github.com/jordanhoare/dotfiles/blob/main/.claude/docs/adr/0011-windows-bootstrap.md). Everything else - shell, prompt, tmux, nvim - runs inside WSL and reads config from the dotfiles repo on the Windows filesystem.

## 1. winutil (one-time)

Run in PowerShell as Administrator to debloat a fresh Windows install:

```powershell
irm "https://christitus.com/win" | iex
```

## 2. Clone the repo

```powershell
git clone https://github.com/jordanhoare/dotfiles.git D:\repositories\dotfiles
```

The repo lives at `D:\repositories\dotfiles` on Windows and `/mnt/d/repositories/dotfiles` from inside WSL - same files, two views (see ADR 0006).

## 3. Bootstrap

From an elevated PowerShell (or any PowerShell if Developer Mode is enabled in **Settings -> For developers**):

```powershell
D:\repositories\dotfiles\win\bootstrap.ps1
```

Imports every app declared in `win/winget.json` (WSL, Obsidian, Bitwarden, Docker Desktop, Firefox, Claude Code, the GitHub CLI (`gh`), Windows Terminal, and Zed) and creates per-file symlinks under `%APPDATA%` so Windows-side Zed reads config straight from the repo. Idempotent - safe to re-run after editing `win/winget.json` or adding files under `config/zed/`.

Ghostty has no official Windows release as of mid-2026 and community ports do not meet the bar for inclusion. Windows-side terminal use defaults to Windows Terminal (preinstalled on Windows 11, declared in `winget.json` for explicitness); the actual Ghostty runs inside WSL via `make switch`.

If you've added Windows apps manually and want to capture them in the manifest:

```powershell
winget export --output D:\repositories\dotfiles\win\winget.json
```

## 4. WSL (optional)

If you also want the Linux side of the dotfiles active:

```powershell
wsl --install -d Ubuntu-24.04
```

Restart when prompted and complete the Ubuntu user setup.

## 5. Inside WSL

```bash
sudo apt install -y git curl make
```

Install Nix: https://nixos.org/download/#nix-install-linux

Open a new shell to pick up the Nix environment.

## 6. Activate WSL

Installs every package, links every config file under `~/.config`, and runs `mise install` for managed runtimes:

```bash
cd /mnt/d/repositories/dotfiles
make switch
```

## 7. Restore secrets

Logs in to Bitwarden, restores both SSH keys, and decrypts the private git profile to `~/.config/git/private`:

```bash
make secrets
```

## 8. Swap remote to SSH

```bash
git remote set-url origin git@personal:jordanhoare/dotfiles.git
```

Done. See [Home](Home) for updating, identity switching, and other daily ops.
