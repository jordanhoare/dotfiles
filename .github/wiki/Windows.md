# Windows

Windows-native apps are managed declaratively via [winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/). The app list lives at `windows/winget.json` in this repo.

## Bootstrap

### 1. winutil (one-time)

Run in PowerShell as Administrator to debloat and tweak a fresh Windows install:

```powershell
irm "https://christitus.com/win" | iex
```

### 2. winget

```powershell
winget import --import-file D:\repositories\dotfiles\windows\winget.json --accept-package-agreements --accept-source-agreements
```

This installs WSL, VSCode, Obsidian, Bitwarden, Docker Desktop, Firefox, Claude Code, and Ghostty.

### 3. WSL

WSL is installed by winget above. Complete setup:

```powershell
wsl --install -d Ubuntu
```

Restart when prompted, complete the Ubuntu user setup, then continue with [Setup - WSL](Setup-WSL).

## Adding Windows apps

Add the package identifier to `windows/winget.json` and run:

```powershell
winget import --import-file D:\repositories\dotfiles\windows\winget.json --accept-package-agreements --accept-source-agreements
```

Never install Windows apps manually outside of winget - keep `winget.json` as the source of truth.

## Config symlinks

Some Windows apps store config in `%APPDATA%` and need a manual symlink to the repo. See:

- [Ghostty](Windows-Ghostty)
- [VSCode](Windows-VSCode)
