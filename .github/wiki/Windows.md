# Windows

## 1. Debloat (one-time)

Run in PowerShell as Administrator.

```powershell
irm "https://christitus.com/win" | iex
```

## 2. Install

From an elevated PowerShell, or any PowerShell with Developer Mode on. Installs git, mise, and PowerShell 7 with winget, clones the repo to `D:\repositories\dotfiles`, imports every app in `win/winget.json`, and links the configs.

```powershell
irm https://raw.githubusercontent.com/jordanhoare/dotfiles/main/install.ps1 | iex
```

Open a new shell afterwards.

## 3. Restore secrets

Logs in to Bitwarden, restores both SSH keys and gh logins, and decrypts every `*.sops` file to its target.

```powershell
mise run secrets
```

## 4. Swap remote to SSH

```powershell
git remote set-url origin git@personal:jordanhoare/dotfiles.git
```

## 5. WSL (optional)

Installs Ubuntu. Restart when prompted and finish the user setup.

```powershell
wsl --install -d Ubuntu-24.04
```

Then follow [Linux](Linux) inside WSL. The install script reuses the clone at `/mnt/d/repositories/dotfiles`, so one checkout serves both sides. The first run enables systemd and asks for a `wsl --shutdown` from Windows; rerun `mise run bootstrap` after the restart.

Done. See [Home](Home) for updating, identity switching, and other daily ops.
