# Windows bootstrap

## Step 1 - winutil (manual, one-time)

Run in PowerShell as Administrator:

```powershell
irm "https://christitus.com/win" | iex
```

Use winutil to apply tweaks and debloat settings. This is interactive and has no config file - run it once on a fresh Windows install.

## Step 2 - clone the repo

```powershell
git clone https://github.com/jordanhoare/dotfiles.git D:\repositories\dotfiles
```

## Step 3 - bootstrap

From an elevated PowerShell (or any PowerShell if Developer Mode is enabled in Settings > For developers):

```powershell
D:\repositories\dotfiles\win\bootstrap.ps1
```

The script runs `winget import` against `win/winget.json` (installs WSL, Obsidian, Bitwarden, Docker Desktop, Firefox, Claude Code, the GitHub CLI, Windows Terminal, and Zed) and creates per-file symlinks under `%APPDATA%` so Windows-side Zed reads config straight from the repo. Idempotent: safe to re-run after adding apps to `winget.json` or files to `config/zed/`. See ADR 0011.

Ghostty has no official Windows release as of mid-2026 and community ports do not meet the bar for inclusion. Windows-side terminal use defaults to Windows Terminal (preinstalled on Windows 11, declared in `winget.json` for explicitness); the actual Ghostty runs inside WSL via `make switch`.

To export the current installed-app state back into `winget.json` (after manually adding apps and wanting to capture them):

```powershell
winget export --output winget.json
```

## Step 4 - WSL (optional)

If you also want the Linux side of the dotfiles active, install WSL:

```powershell
wsl --install -d Ubuntu-24.04
```

Restart when prompted, then complete the Ubuntu user setup. Inside the WSL shell, install Nix following the Linux instructions at https://nixos.org/download/#nix-install-linux, then activate the WSL configuration:

```bash
cd /mnt/d/repositories/dotfiles
make switch
```

The repo at `D:\repositories\dotfiles` is reachable from inside WSL as `/mnt/d/repositories/dotfiles` (see ADR 0006), so the same clone serves both sides.
